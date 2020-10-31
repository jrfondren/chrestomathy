import std.stdio : stdin, writeln;
import maxmind.db : Database;
import std.exception : assumeUnique;

void main() {
    auto db = new Database("GeoLite2-Country.mmdb");
    long n;
    foreach (line; stdin.byLine) {
        try {
            auto result = db.lookup(line.assumeUnique);
            if (result !is null && result.country !is null)
                n += result.country.iso_code.get!string.length;
        } catch (Exception e) { }
    }
    writeln(n);
}
