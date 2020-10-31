use std::net::IpAddr;
use maxminddb::geoip2;
use std::io::{self, BufRead};

fn main() {
    let reader = maxminddb::Reader::open_readfile("GeoLite2-Country.mmdb").unwrap();
    let mut n: usize = 0;
    let stdin = io::stdin();
    for line in stdin.lock().lines() {
        if let Ok(line) = line {
            if let Ok(ip) = line.parse::<IpAddr>() {
                if let Ok(city) = reader.lookup::<geoip2::City>(ip) {
                    if let Some(country) = city.country {
                        if let Some(isocode) = country.iso_code {
                            n += isocode.len();
                        }
                    }
                }
            }
        }
    }
    println!("{}", n);
}
