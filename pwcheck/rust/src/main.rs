use rust_embed::RustEmbed;
use std::ffi::{CString, CStr};
use libc::c_char;
use regex::Regex;
use std::io::BufRead;
#[macro_use] extern crate lazy_static;

#[derive(RustEmbed)]
#[folder = "assets/"]
struct Assets;

#[link(name = "crypt")]
extern {
    fn crypt(key: *const c_char, salt: *const c_char) -> *const c_char;
}

fn encrypts_to(key: &CString, salt: &CString, hash: &CString) -> bool {
    unsafe {
        let ret = crypt(key.as_ptr(), salt.as_ptr());
        if ret == std::ptr::null() { return false }
        hash.as_c_str() == CStr::from_ptr(ret)
    }
}

#[derive(Debug, PartialEq)]
enum Strength {
    Ok,
    None,
    DES,
    Weak(String),
    WeakDES(String),
}

fn key_strength(hash: String, keys: &Vec<CString>) -> Strength {
    lazy_static! {
        static ref HASHRE: Regex =
            Regex::new(r#"(^[$](?:1|2a|5|6)[$][^$]+[$])"#).unwrap();
    }
    // man 5 shadow
    if hash == "*" { Strength::Ok }
    else if hash == "" { Strength::None }
    else if hash.chars().next().unwrap() == '!' { Strength::Ok }
    else if let Some(caps) = HASHRE.captures(&hash) {
        let salt = CString::new(&caps[1]).unwrap();
        let hash = CString::new(hash.into_bytes()).unwrap();
        for key in keys {
            if encrypts_to(&key, &salt, &hash) {
                return Strength::Weak(key.clone().into_string().unwrap())
            }
        }
        Strength::Ok
    } else {
        let salt = CString::new(&hash[0..2]).unwrap();
        let hash = CString::new(hash.into_bytes()).unwrap();
        for key in keys {
            if encrypts_to(&key, &salt, &hash) {
                return Strength::WeakDES(key.clone().into_string().unwrap())
            }
        }
        Strength::DES
    }
}

fn passwords(name: &'static str) -> Vec<CString> {
    std::str::from_utf8(&Assets::get(name).unwrap()).unwrap()
        .lines()
        .map(|s: &str| CString::new(s).unwrap())
        .collect()
}

fn main() {
    let cli = clap::App::new("pwcheck")
        .version("0.1.0")
        .author("Julian Fondren")
        .about("Checks /etc/shadow passwords against prepared password lists")
        .arg(clap::Arg::with_name("25")
            .long("25")
            .help("Use the 'top 25' password list")
            .takes_value(false))
        .arg(clap::Arg::with_name("500")
            .long("500")
            .help("Use the 'top 500' password list")
            .takes_value(false))
        .arg(clap::Arg::with_name("file")
             .long("file")
             .help("Check a file with one hash per line, instead of /etc/shadow")
             .takes_value(true))
        .get_matches();
    let hostname = hostname::get().unwrap().into_string().unwrap();
    let mut keys = Vec::new();
    if cli.is_present("25") { keys.append(&mut passwords("top25.list")) }
    if cli.is_present("500") { keys.append(&mut passwords("top500.list")) }
    if keys.is_empty() {
        eprintln!("No passwords to look for. Try passing --25 or --500");
    } else if let Some(file) = cli.value_of("file") {
        if let Ok(file) = std::fs::File::open(file) {
            for line in std::io::BufReader::new(file).lines() {
                if let Ok(line) = line {
                    match key_strength(line, &keys) {
                        Strength::Weak(pass) => println!("Found {}", pass),
                        Strength::WeakDES(pass) => println!("DES {}", pass),
                        _ => (),
                    }
                }
            }
        }
    } else {
        for user in shadow::Shadow::iter_all() {
            match key_strength(user.password, &keys) {
                Strength::Ok => (),
                Strength::None =>
                    println!("{}: {} lacks a password! This is dangerous!",
                        hostname, user.name),
                Strength::DES =>
                    println!("{}: {} has an old DES-style password hash! This is dangerous!",
                        hostname, user.name),
                Strength::Weak(pass) =>
                    println!("{}: {} has weak password of: {}",
                        hostname, user.name, pass),
                Strength::WeakDES(pass) =>
                    println!("{}: {} has weak (DES!) password of: {}",
                        hostname, user.name, pass),
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_encrypts_to() {
        assert!(encrypts_to(
                &CString::new("password").unwrap(),
                &CString::new("$1$YzTLPnhJ$").unwrap(),
                &CString::new("$1$YzTLPnhJ$OZoHkjAYlIgCmOKQi.PXn.").unwrap(),
        ));
        assert!(encrypts_to(
                &CString::new("monkey").unwrap(),
                &CString::new("lh").unwrap(),
                &CString::new("lhBnWgIh1qed6").unwrap(),
        ));
    }

    #[test]
    fn test_key_strength() {
        let keys = vec!(CString::new("password").unwrap(), CString::new("monkey").unwrap());
        assert_eq!(
            Strength::Weak("password".to_string()),
            key_strength("$1$YzTLPnhJ$OZoHkjAYlIgCmOKQi.PXn.".to_string(), &keys)
        );
        assert_eq!(
            Strength::Ok,
            key_strength("$1$YzTLPnhJ$mvaycoMIyVr/NaEHKzB5H0".to_string(), &keys)
        );
        assert_eq!(Strength::Ok, key_strength("!foo".to_string(), &keys));
        assert_eq!(Strength::Ok, key_strength("*".to_string(), &keys));
        assert_eq!(Strength::None, key_strength("".to_string(), &keys));
        assert_eq!(Strength::DES, key_strength("foo".to_string(), &keys));
        assert_eq!(
            Strength::WeakDES("monkey".to_string()),
            key_strength("lhBnWgIh1qed6".to_string(), &keys)
        );
    }
}
