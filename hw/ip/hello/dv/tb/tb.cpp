#include "Vhello.h"
#include "verilated.h"

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Vhello* top = new Vhello;

    printf("Hello TB\n");
    while (!Verilated::gotFinish()) {
        top->eval();
    }
    printf("TEST PASSED CHECKS\n");
    delete top;
    exit(0);
}
