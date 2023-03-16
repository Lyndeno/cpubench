use std::{thread, time::Duration};

use csv::Writer;
use procfs::CpuInfo;

fn main() {
    println!("Hello, world!");
    match cpuid::clock_frequency() {
        Some(f) => println!("CPU speed: {} MHz", f),
        None => println!("Could not get speed"),
    };
    let mut wtr = Writer::from_path("test.csv").unwrap();
    loop {
        let mut v = Vec::new();
        print!("{}[2J", 27 as char);
        let info = CpuInfo::new().unwrap();
        for n in 0..info.num_cores() {
            let s = info.get_field(n, "cpu MHz").unwrap();
            println!("CPU: {}, Freq: {}", n, s);
            v.push(s);
        }
        wtr.serialize(v).unwrap();
        wtr.flush().unwrap();
        thread::sleep(Duration::from_millis(1000));
    }
}
