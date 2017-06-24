//
//  mm1k.hpp
//  MM1K
//
//  Copyright © 1395 AP Nima Mohammadi. All rights reserved.
//

#ifndef mm1k_hpp
#define mm1k_hpp

#include <stdio.h>

//
//  main.cpp
//
//
//  Created by Nima Mohammadi
//

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <random>
#include <math.h>

#include <time.h>

using namespace std;

double gamma(int n, double mu, double theta_bar, int theta_type){
    if (theta_type == 0){
        if (n==0)
            return 0;
        else
            return mu / (exp((mu*theta_bar)/n) - 1);
    }
    else
        if (n==0)
            return 0;
        else
            return n / theta_bar;
}

double min(double a, double b){
    if (a < b)
        return a;
    return b;
}

vector<double> queue_simulator(double lambda, double mu, double theta, int K, int theta_type, int sim_counts, int warmup=100000){
    //typedef pair<double, double> sw;
    typedef std::tuple<double, double, int> sw;
    vector<sw> queue;
    int current_waiting_count = 0;
    int jid = 0;
    int blocked = 0;
    int deserted = 0;
    int completed = 0;
    double next_event_t = 0;
    double upcoming_job_t = 0;
    
    double total_share = .0;
    double customer_share = .0;
    
    float class_weights[] = {1, 2};
    int class_current_customers[] = {0, 0};
    int class_deserted[] = {0, 0};
    
    for (int i=0; i<K; i++)
        queue.push_back(make_tuple(0.0, 0.0, -1));
    //
    //    warmup=pow(10, 7);
    
    std::random_device rd;
    std::mt19937 gen (rd());
    std::exponential_distribution<> lambda_rng_exp(lambda);
    //    std::uniform_int_distribution<> lambda_rng(0, 2*lambda);
    std::exponential_distribution<> mu_rng_exp(1.0/mu);
    std::exponential_distribution<> theta_rng_exp(1.0/theta);
    //    std::uniform_int_distribution<> mu_rng(0, 2*mu);
    std::uniform_real_distribution<> theta_rng(.0, 2.0*theta);
    std::uniform_real_distribution<> class_rng(.0, 1.0);
    
    
    while (jid < sim_counts){
        class_current_customers[0] = 0;
        class_current_customers[1] = 0;
        for (int i=0; i<current_waiting_count; i++){
            if (std::get<2>(queue[i])!=-1)
                class_current_customers[std::get<2>(queue[i])]++;
        }
        total_share = class_weights[0] * class_current_customers[0] + class_weights[1] * class_current_customers[1];
        int i = 0;
        while (i<current_waiting_count){
            customer_share = class_weights[std::get<2>(queue[i])] / total_share;
            std::get<0>(queue[i]) -= next_event_t * customer_share;
            std::get<1>(queue[i]) -= next_event_t;
            if (std::get<0>(queue[i]) <= 0.0001){
                if (jid > warmup)
                    completed++;
                current_waiting_count--;
                queue[i] = queue[current_waiting_count];
                i--;
            }
            else if (std::get<1>(queue[i]) <= 0.0001){
                if (jid > warmup){
                    deserted++;
                    class_deserted[std::get<2>(queue[i])]++;
                }
                current_waiting_count--;
                queue[i] = queue[current_waiting_count];
                i--;
            }
            i++;
        }
        
        upcoming_job_t -= next_event_t;
        if (upcoming_job_t <= 0.0){
            upcoming_job_t = lambda_rng_exp(gen);
            jid++;
            if (current_waiting_count < K){
                if (theta_type == 1){
                    std::get<0>(queue[current_waiting_count]) = mu_rng_exp(gen); //THETA(1.0/mu, theta_type);
                    std::get<1>(queue[current_waiting_count]) = theta_rng_exp(gen);//THETA(1.0/theta, theta_type);
                } else {
                    std::get<0>(queue[current_waiting_count]) = mu_rng_exp(gen);
                    std::get<1>(queue[current_waiting_count]) = theta;
                }
                if (class_rng(gen) > .5)
                    std::get<2>(queue[current_waiting_count]) = 1;
                else
                    std::get<2>(queue[current_waiting_count]) = 0;
                current_waiting_count++;
            }
            else{
                if (jid > warmup)
                    blocked++;
            }
        }
        
        next_event_t = upcoming_job_t;
        for (i=0; i<current_waiting_count; i++){
            next_event_t = min(next_event_t, min(std::get<0>(queue[i]), std::get<1>(queue[i])*current_waiting_count));
        }
        
        
    }
    completed += current_waiting_count;
    //    cout << blocked << ", " << deserted << ", " << completed << endl;
    double P_b = blocked / double(jid - warmup);
    double P_d = deserted / double(jid - warmup);
    
    double P_d0 = class_deserted[0] / double(jid - warmup);
    double P_d1 = class_deserted[1] / double(jid - warmup);
    
    vector<double> result;
    result.push_back(P_b);
    result.push_back(P_d);
    result.push_back(P_d0);
    result.push_back(P_d1);
    return result;
    
}

#endif /* mm1k_hpp */
