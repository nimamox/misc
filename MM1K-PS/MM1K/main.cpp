#include "mm1k.hpp"

int main(){
    ifstream paramfile;
    paramfile.open("parameters.conf");
    double theta, mu;
    paramfile >> theta >> mu;
    
    //theta = 2.0; mu = 1.0;
    
    cout << "Running for parameters\nTheta = " << theta << "\nMu = " << mu << endl;
    
    vector<double> r_sim, r_anal;
    for (int type=0; type<2; type++){
        if (type)
            cout << "\nExp theta:" << endl;
        else
            cout << "\nFixed theta:" << endl;
        for (int l=5; l<=15 ;l+=5){
            cout << "  Running simulation case for lambda=" << l << endl;
            r_sim = queue_simulator(l, mu, theta, 10, type, pow(10, 7), pow(10, 5));
            cout << "\tP_b=" << r_sim[0] << endl;
            cout << "\tP_d=" << r_sim[1] << endl;
            cout << "  Running analytical case for lambda=" << l << endl;
            r_anal = closed_form(l, mu, theta, 10, type);
            cout << "\tP_b=" << r_anal[0] << endl;
            cout << "\tP_d=" << r_anal[1] << endl;
            cout << "\tdiff P_b=" << abs(r_sim[0] - r_anal[0]) << endl;
            cout << "\tdiff P_d=" << abs(r_sim[1] - r_anal[1]) << endl;
            cout << "******************" << endl;
        }
    }
    return 0;
}

