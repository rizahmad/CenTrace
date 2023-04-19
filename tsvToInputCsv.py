import argparse
import csv

def main():
    parser = argparse.ArgumentParser(
                        prog='tsvToInputCsv.py',
                        description='Converts WIBM TSV out file to CenTrace input CSV')
    parser.add_argument('-i', required=True)
    args = parser.parse_args()
    
    INPUT_FILE = args.i
    OUTPUT_FILE = INPUT_FILE+"_input.csv"

    endpoints = {}
    endpoints["104.16.100.49"] = 13335
    endpoints["116.202.120.183"] = 24940
    endpoints["94.20.71.165"] = 29049
    #endpoints["46.32.168.255"] = 211790

    domains = set()
    with open(INPUT_FILE) as fd:
        rd = csv.reader(fd, delimiter="\t", quotechar='"')
        for i, row in enumerate(rd):
            if i > 1:
                domains.add(row[0])

    with open(OUTPUT_FILE, 'w', newline='') as fd:
        wd = csv.writer(fd, delimiter=",")
        for ip in endpoints:
            for d in domains:
                wd.writerow([ip, d, endpoints[ip]])

if __name__ == "__main__":
    main()


