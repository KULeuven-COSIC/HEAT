rm gmdh
g++ -std=c++11 -funroll-loops -O3 -w -g  -I.. -I/volume1/fturan/bin/nfllib/include -L/volume1/fturan/bin/nfllib/lib gmdh.cpp -o gmdh  -lnfllib -lmpfr -lgmpxx -lgmp -larmadillo
