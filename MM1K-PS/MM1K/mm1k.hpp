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

//inline float uniform_rand(float a, float b)
//{
//    static default_random_engine generator;
//    generator.seed((unsigned int)time(NULL));
//    static uniform_real_distribution<double> distribution(a, b);
//    return distribution(generator);
//}

//double rnd(){
////    return ((double) rand() / (RAND_MAX));
//    return uniform_rand(0, 1);
//}
//
//
//int randi(int min, int max){
//    return min + (rand() % (int)(max - min + 1));
//}

//double THETA(double theta, int kind){
//    double r = rnd();
//    if (kind==0)
//        return r * 2 * (1.0/theta);
//    else
//        return -log(1 - r) / theta;
//}

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
    typedef pair<double, double> sw;
    vector<sw> queue;
    int current_waiting_count = 0;
    int jid = 0;
    int blocked = 0;
    int deserted = 0;
    int completed = 0;
    double next_event_t = 0;
    double upcoming_job_t = 0;
    for (int i=0; i<K; i++)
        queue.push_back(make_pair(0.0, 0.0));
//    
//    warmup=pow(10, 7);
    
    std::random_device rd;
    std::mt19937 gen (rd());
    std::exponential_distribution<> lambda_rng_exp(lambda);
    std::uniform_int_distribution<> lambda_rng(0, 2*lambda);
    std::exponential_distribution<> mu_rng_exp(mu);
    std::exponential_distribution<> theta_rng_exp(1.0/theta);
    std::uniform_int_distribution<> mu_rng(0, 2*mu);
    std::uniform_int_distribution<> theta_rng(0, 2*theta);
    
    while (jid < sim_counts){
        int i = 0;
        while (i<current_waiting_count){
            queue[i].first -= next_event_t / current_waiting_count;
            queue[i].second -= next_event_t;
            if (queue[i].first <= 0.0001){
                if (jid > warmup)
                    completed++;
                current_waiting_count--;
                queue[i] = queue[current_waiting_count];
                i--;
            }
            else if (queue[i].second <= 0.0001){
                if (jid > warmup)
                    deserted++;
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
                    queue[current_waiting_count].first = mu_rng_exp(gen); //THETA(1.0/mu, theta_type);
                    queue[current_waiting_count].second = theta_rng_exp(gen);//THETA(1.0/theta, theta_type);
                } else {
                    queue[current_waiting_count].first = mu_rng_exp(gen);
                    queue[current_waiting_count].second = theta;//theta_rng(gen);
                }
                current_waiting_count++;
                //                if (current_waiting_count > 1)
                //                    cout << jid << " " << current_waiting_count<< endl;
            }
            else{
                if (jid > warmup)
                    blocked++;
            }
        }
        
        next_event_t = upcoming_job_t;
        for (i=0; i<current_waiting_count; i++){
            next_event_t = min(next_event_t, min(queue[i].first, queue[i].second*current_waiting_count));
        }
        
        
    }
    completed += current_waiting_count;
//    cout << blocked << ", " << deserted << ", " << completed << endl;
    double P_b = (blocked) / double(jid - warmup);
    double P_d = (deserted) / double(jid - warmup);
    
    vector<double> result;
    result.push_back(P_b);
    result.push_back(P_d);
    return result;
    
}

vector<double> closed_form(double lambda, double mu, double theta, int K, int theta_type){
    vector<double> P_i;
    for (int i=0; i<K; i++){
        P_i.push_back(0);
    }
    double sumtmp = 1.0, multmp;
    for (int i=1; i<=K; i++){
        multmp = 1.0;
        for (int j=1; j<=i; j++)
            multmp *= mu + gamma(j, mu, theta, theta_type);
        sumtmp += pow(lambda, i) / multmp;
    }
    
    
    P_i[0] = pow(sumtmp, -1);
    for (int n=1; n<=K; n++){
        multmp = 1.0;
        for (int i=1; i<=n; i++)
            multmp *= mu + gamma(i, mu, theta, theta_type);
        P_i[n] = P_i[0] * pow(lambda, n) / multmp;
    }
    
    vector<double> result;
    double P_b = P_i[K];
    double P_d = 1 - (mu / lambda) * (1 - P_i[0]) - P_b;
//    cout << P_b << "\t" << P_d << endl;
    result.push_back(P_b);
    result.push_back(P_d);
    return result;
}

#endif /* mm1k_hpp */
