import regex.pcre
import os
import flag

@[xdoc: 'Look for very weak passwords']
@[name: 'pwcheck']
@[version: '0.1']
struct Config {
	top25  bool @[long: 25]
	top500 bool @[long: 500]
	file   string
	help   bool @[short: h]
}

// vfmt off
struct Safe {}
struct Blank {}
struct DES {}
struct WeakDES { pass string }
struct Weak { pass string }
struct Erroneous {}
type Weakness = Safe | Blank | DES | WeakDES | Weak | Erroneous
// vfmt on

fn is_weak(known []string, hash string) Weakness {
	if hash == '*' {
		return Safe{}
	}
	if hash == '' {
		return Blank{}
	}
	if hash[0] == `!` {
		return Safe{}
	}
	if hash.len < 3 {
		return Erroneous{}
	}
	hash_re := pcre.compile(r'[$](?:1|2a|5|6)[$][^$]+[$]') or { panic(err) }
	salt, des := if m := hash_re.find(hash) {
		m.text, false
	} else {
		hash[0..2], true
	}
	for pass in known {
		if hash == crypt(pass, salt) or { continue } {
			return if des { WeakDES{pass} } else { Weak{pass} }
		}
	}
	return if des { DES{} } else { Safe{} }
}

#include <crypt.h>
#flag -lcrypt

fn C.crypt(phrase &char, salt &char) &char

fn crypt(phrase string, salt string) ?string {
	res := C.crypt(phrase.str, salt.str)
	if res == unsafe { nil } {
		return none
	}
	return unsafe { cstring_to_vstring(res) }
}

fn lint(user string, weak Weakness) {
	match weak {
		Safe {}
		Blank { println('${user} lacks a password! This is dangerous!') }
		DES { println('${user} has an old DES-style password hash! This is dangerous!') }
		WeakDES { println('${user} has a weak (DES!) password of: ${weak.pass}') }
		Weak { println('${user} has a weak password of: ${weak.pass}') }
		Erroneous {}
	}
}

config, rest := flag.to_struct[Config](os.args, skip: 1)!
if rest.len > 0 {
	eprintln('unhandled args: ${rest}')
	exit(1)
}
if config.help {
	eprintln(flag.to_doc[Config](
		fields: {
			'25':   "Use the 'top 25' password list"
			'500':  "Use the 'top 500' password list"
			'file': 'Check a file with one hash per line, instead of /etc/shadow'
		}
	)!)
	exit(1)
}
known := if config.top25 {
	$embed_file('../ocaml/assets/top25.list').to_string().split_into_lines()
} else if config.top500 {
	$embed_file('../ocaml/assets/top500.list').to_string().split_into_lines()
} else {
	eprintln('No passwords to look for. Try passing --25 or --500')
	exit(1)
}
if config.file == '' {
	for line in os.read_lines('/etc/shadow')! {
		parts := line.split_nth(':', 3)
		lint(parts[0], is_weak(known, parts[1]))
	}
} else {
	for line in os.read_lines(config.file)! {
		lint(config.file, is_weak(known, line))
	}
}
