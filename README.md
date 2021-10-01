# Performance test between serial and parallel execution

## Performance results

### PowerShell 7.1.4:
- Serial execution:
```bash
pwsh aro_rp_versions.ps1  2.80s user 0.57s system 21% cpu 15.628 total
```
- PowerShell [runspace pools](https://github.com/25region/performance_test/blob/main/aro_rp_versions_runspace_pool.ps1):
```bash
pwsh aro_rp_versions_runspace_pool.ps1  2.29s user 0.63s system 144% cpu 2.025 total
```

### Python 3.9.7:
- Serial execution:
```bash
python3 aro_rp_versions.py  1.77s user 0.24s system 13% cpu 15.157 total
```
- Python with [multiprocessing](https://github.com/25region/performance_test/blob/main/aro_rp_versions_mp.py):
```bash
python3 aro_rp_versions_mp.py  9.00s user 4.72s system 538% cpu 2.549 total
```
- Python with [multithreading](https://github.com/25region/performance_test/blob/main/aro_rp_versions_mt.py):
```bash
python3 aro_rp_versions_mt.py  1.39s user 0.55s system 145% cpu 1.325 total
```

### Golang 1.15.15:
- Serial execution:
```bash
go run main.go  0.61s user 1.06s system 37% cpu 4.428 total
```
- Go [routines](https://github.com/25region/aro-rp-versions/blob/main/main.go):
```bash
go run main.go  0.67s user 1.31s system 112% cpu 1.757 total
```
- Compiled binary with go [routines](https://github.com/25region/aro-rp-versions/blob/main/main.go):
```bash
./aro-rp-versions  0.18s user 0.10s system 53% cpu 0.542 total
```
