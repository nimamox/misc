//
//  main2.cpp
//  MM1K
//
//  Created by Nima Mohammadi 
//


#include "mm1k.hpp"

int main(){
    int sims_counts = pow(10, 7);
    int warmup = pow(10, 5);
    vector<double> r_sim, r_anal;
    ofstream output("output_fixed.csv");
    output.precision(12);
    output << "lambda, sim_pb, sim_pd, sim_pd1, sim_pd2" << endl;
    for (double l=.1; l<=20.1 ;l+=.1){
        cout << "Lambda=" << l << endl;
        r_sim = queue_simulator(l, 1.0, 2.0, 10, 0, sims_counts, warmup);
        output << l << ", " << r_sim[0] << ", " << r_sim[1] << ", " << r_sim[2] << ", " << r_sim[3] << endl;
    }
    output.close();
    
    ofstream output2("output_exp.csv");
    output2.precision(12);
    output2 << "lambda, sim_pb, sim_pd, sim_pd1, sim_pd2" << endl;
    for (double l=.1; l<=20.1 ;l+=.1){
        cout << "Lambda=" << l << endl;
        r_sim = queue_simulator(l, 1.0, 2.0, 10, 1, sims_counts, warmup);
        output2 << l << ", " << r_sim[0] << ", " << r_sim[1] << ", " << r_sim[2] << ", " << r_sim[3] << endl;
    }
    output2.close();
    return 0;
}
