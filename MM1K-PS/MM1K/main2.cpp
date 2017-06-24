//
//  main2.cpp
//  MM1K
//
//  Created by Nima Mohammadi
//


#include "mm1k.hpp"

int main(){
    cout.precision(17);
    vector<double> r_sim, r_anal;
    ofstream output;
    double abserr, relerr;
    double abserr2, relerr2;
    
    for (int theta_type=0; theta_type<2; theta_type++){
        if (theta_type==0)
            output.open("output_fixed.csv");
        else
            output.open("output_exp.csv");
        output.precision(17);
        output << "lambda, sim_pb, anal_pb, abserr, relerr, sim_pd, anal_pd, abserr, relerr" << endl;
        for (double l=0.1; l<20.1 ;l+=.1){
            cout << "Lambda=" << l << endl;
            double sim_pb = 0;
            double sim_pd = 0;
            r_sim = queue_simulator(l, 1.0, 2.0, 10, theta_type, pow(10, 7), 1000);
            sim_pb = r_sim[0];
            sim_pd = r_sim[1];
            r_anal = closed_form(l, 1.0, 2.0, 10, theta_type);
            abserr = abs(sim_pb - r_anal[0]);
            relerr = abserr / r_sim[0];
            abserr2 = abs(sim_pd - r_anal[1]);
            relerr2 = abserr2 / r_sim[1];
            cout << abserr << ", " << relerr << ", " << abserr2 << ", " << relerr2 << endl;
            output << l << ", " << sim_pb << ", " << r_anal[0] << ", " << abserr << ", " << relerr << ", " << sim_pd << ", " << r_anal[1] << ", " << abserr2 << ", " << relerr2 << endl;
        }
        output.close();
    }
    return 0;
}
