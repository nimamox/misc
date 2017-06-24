#include "mm1k.hpp"

int main(){
    ifstream paramfile;
    paramfile.open("parameters.conf");
    double theta, mu;
    paramfile >> theta >> mu;
    
//    theta = 2.0; mu = 1.0;
    
    cout << "Running for parameters\nTheta = " << theta << "\nMu = " << mu << endl;
    
    vector<double> r;
    for (int type=0; type<2; type++){
        if (type)
            cout << "\nExponential theta:" << endl;
        else
            cout << "\nFixed theta:" << endl;
        for (int l=5; l<=15 ;l+=5){
            cout << "  Simulation solutions for lambda=" << l << endl;
            r = queue_simulator(l, mu, theta, 10, type, pow(10, 7), pow(10, 5));
            cout << "\tP_b=" << r[0] << endl;
            cout << "\tP_d=" << r[1] << endl;
            cout << "\tP_d0=" << r[2] << endl;
            cout << "\tP_d1=" << r[3] << endl;
        }
    }
    return 0;
}
