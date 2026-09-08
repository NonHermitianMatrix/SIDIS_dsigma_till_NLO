
#include <cmath>
#include <algorithm>
#include <string>
#include <sstream>
#include <stdexcept>
#include <cstring>
extern "C" int sidis_load_program(const char*);
extern "C" int sidis_eval(int,const double*,double*);
extern "C" void sidis_pdf(double,double,double*);
extern "C" void sidis_kkp(double,double,int,double*);
extern "C" void sidis_kretzer(double,double,int,double*);
extern "C" void sidis_set_alpha(double,double,double);
extern "C" double sidis_alpha(double);
static constexpr double Ee=27.6,Ep=820,alphaEM=0.0072973525643,pb=389379372.17185944;
static int ids[6][8][3];static bool included[6][8];
static unsigned channelMask=(1u<<6)-1;
extern "C" void sidis_channel_mask(unsigned mask){channelMask=mask;}
static bool initialized=false;
static std::string failure;
static double map_s(double Q2,double y,double pt,double zH,double xi,double s23){return -Q2*(((1.0/4.0)*Q2/(Ee*Ep*y)) - xi)/((1.0/4.0)*Q2/(Ee*Ep*y));}
static double map_t(double Q2,double y,double pt,double zH,double xi,double s23){return (Q2*pow(pt, 2)*xi + Q2*s23*((1.0/4.0)*Q2/(Ee*Ep*y))*pow(zH, 2) - pow(pt, 2)*s23*((1.0/4.0)*Q2/(Ee*Ep*y)))/(Q2*((1.0/4.0)*Q2/(Ee*Ep*y))*pow(zH, 2) - Q2*xi*pow(zH, 2) - pow(pt, 2)*((1.0/4.0)*Q2/(Ee*Ep*y)));}
static double map_u(double Q2,double y,double pt,double zH,double xi,double s23){return -Q2*xi*pow(zH, 2)*(Q2*((1.0/4.0)*Q2/(Ee*Ep*y)) - Q2*xi + s23*((1.0/4.0)*Q2/(Ee*Ep*y)))/(((1.0/4.0)*Q2/(Ee*Ep*y))*(Q2*((1.0/4.0)*Q2/(Ee*Ep*y))*pow(zH, 2) - Q2*xi*pow(zH, 2) - pow(pt, 2)*((1.0/4.0)*Q2/(Ee*Ep*y))));}
static double map_xHat(double Q2,double y,double pt,double zH,double xi,double s23){return ((1.0/4.0)*Q2/(Ee*Ep*y))/xi;}
static double map_xB(double Q2,double y,double pt,double zH,double xi,double s23){return (1.0/4.0)*Q2/(Ee*Ep*y);}
static double map_zeta(double Q2,double y,double pt,double zH,double xi,double s23){return (Q2*((1.0/4.0)*Q2/(Ee*Ep*y))*pow(zH, 2) - Q2*xi*pow(zH, 2) - pow(pt, 2)*((1.0/4.0)*Q2/(Ee*Ep*y)))/(zH*(Q2*((1.0/4.0)*Q2/(Ee*Ep*y)) - Q2*xi + s23*((1.0/4.0)*Q2/(Ee*Ep*y))));}
static double map_B(double Q2,double y,double pt,double zH,double xi,double s23){return (Q2*((1.0/4.0)*Q2/(Ee*Ep*y))*pow(zH, 2) - Q2*((1.0/4.0)*Q2/(Ee*Ep*y))*zH - Q2*xi*pow(zH, 2) + Q2*xi*zH - pow(pt, 2)*((1.0/4.0)*Q2/(Ee*Ep*y)))/(((1.0/4.0)*Q2/(Ee*Ep*y))*zH);}
static double map_xi_min(double Q2,double y,double pt,double zH,double xi,double s23){return ((1.0/4.0)*Q2/(Ee*Ep*y))*(Q2*pow(zH, 2) - Q2*zH - pow(pt, 2))/(Q2*zH*(zH - 1));}
static double map_jacobian(double Q2,double y,double pt,double zH,double xi,double s23){return -((1.0/4.0)*Q2/(Ee*Ep*y))*(Q2*((1.0/4.0)*Q2/(Ee*Ep*y))*pow(zH, 2) - Q2*xi*pow(zH, 2) - pow(pt, 2)*((1.0/4.0)*Q2/(Ee*Ep*y)))/(zH*pow(Q2*((1.0/4.0)*Q2/(Ee*Ep*y)) - Q2*xi + s23*((1.0/4.0)*Q2/(Ee*Ep*y)), 2));}
static double map_z_lower(double Q2,double y,double pt,double zH,double xi,double s23){return (1.0/2.0)*(sqrt(Q2)*(((1.0/4.0)*Q2/(Ee*Ep*y)) - 1) + sqrt((((1.0/4.0)*Q2/(Ee*Ep*y)) - 1)*(Q2*((1.0/4.0)*Q2/(Ee*Ep*y)) - Q2 + 4*pow(pt, 2)*((1.0/4.0)*Q2/(Ee*Ep*y)))))/(sqrt(Q2)*(((1.0/4.0)*Q2/(Ee*Ep*y)) - 1));}
static double map_z_upper(double Q2,double y,double pt,double zH,double xi,double s23){return (1.0/2.0)*(sqrt(Q2)*(((1.0/4.0)*Q2/(Ee*Ep*y)) - 1) - sqrt((((1.0/4.0)*Q2/(Ee*Ep*y)) - 1)*(Q2*((1.0/4.0)*Q2/(Ee*Ep*y)) - Q2 + 4*pow(pt, 2)*((1.0/4.0)*Q2/(Ee*Ep*y)))))/(sqrt(Q2)*(((1.0/4.0)*Q2/(Ee*Ep*y)) - 1));}
static double map_sigma_weight_F1(double Q2,double y,double pt,double zH,double xi,double s23){return (1.0/2.0)*pow(M_PI, 2)*pow(alphaEM, 2)*pt/(Ee*Ep*Q2*zH);}
static double map_sigma_weight_F2(double Q2,double y,double pt,double zH,double xi,double s23){return -1.0/2.0*pow(M_PI, 2)*pow(alphaEM, 2)*pt*(4*Ee*Ep*y - 4*Ee*Ep)/(Ee*Ep*pow(Q2, 2)*y*zH);}
static double map_mu2(double Q2,double y,double pt,double zH,double xi,double s23){return (1.0/2.0)*Q2 + (1.0/2.0)*pow(pt, 2);}
static double plusLogarithm(int ch,double ss,double B){if(ch==0)return log(ss/B);if(ch==5)return log(ss/B);if(ch==4)return log(ss/B);throw std::runtime_error("missing plus convention");}
static double linmap(double coordinate,double lower,double upper,double& jac){jac=-lower + upper;return coordinate*(-lower + upper) + lower;}
static double logmap(double coordinate,double lower,double upper,double& jac){jac=lower*exp(coordinate*log(upper/lower))*log(upper/lower);return lower*exp(coordinate*log(upper/lower));}
static void luminosity(int nf,const double*f,const double*d,double*v,double charges[2][4]){
 const double f0=f[0],f1=f[1],f2=f[2],f3=f[3],f4=f[4],f5=f[5],f6=f[6],f7=f[7],f8=f[8],f9=f[9],f10=f[10],d0=d[0],d1=d[1],d2=d[2],d3=d[3],d4=d[4],d5=d[5],d6=d[6],d7=d[7],d8=d[8],d9=d[9],d10=d[10];
 if(nf==4){ v[0]=d1*f1 + d2*f2 + d7*f7 + d8*f8;
 v[1]=d3*f3 + d4*f4 + d5*f5 + d6*f6;
 v[2]=(10.0/9.0)*d0*f0;
 v[3]=(4.0/9.0)*d1*f2 + (4.0/9.0)*d2*f1 + (1.0/9.0)*d3*f4 + (1.0/9.0)*d4*f3 + (1.0/9.0)*d5*f6 + (1.0/9.0)*d6*f5 + (4.0/9.0)*d7*f8 + (4.0/9.0)*d8*f7;
 v[4]=(1.0/9.0)*d1*f3 + (1.0/9.0)*d1*f4 + (1.0/9.0)*d1*f5 + (1.0/9.0)*d1*f6 + (4.0/9.0)*d1*f7 + (4.0/9.0)*d1*f8 + (1.0/9.0)*d2*f3 + (1.0/9.0)*d2*f4 + (1.0/9.0)*d2*f5 + (1.0/9.0)*d2*f6 + (4.0/9.0)*d2*f7 + (4.0/9.0)*d2*f8 + (4.0/9.0)*d3*f1 + (4.0/9.0)*d3*f2 + (1.0/9.0)*d3*f5 + (1.0/9.0)*d3*f6 + (4.0/9.0)*d3*f7 + (4.0/9.0)*d3*f8 + (4.0/9.0)*d4*f1 + (4.0/9.0)*d4*f2 + (1.0/9.0)*d4*f5 + (1.0/9.0)*d4*f6 + (4.0/9.0)*d4*f7 + (4.0/9.0)*d4*f8 + (4.0/9.0)*d5*f1 + (4.0/9.0)*d5*f2 + (1.0/9.0)*d5*f3 + (1.0/9.0)*d5*f4 + (4.0/9.0)*d5*f7 + (4.0/9.0)*d5*f8 + (4.0/9.0)*d6*f1 + (4.0/9.0)*d6*f2 + (1.0/9.0)*d6*f3 + (1.0/9.0)*d6*f4 + (4.0/9.0)*d6*f7 + (4.0/9.0)*d6*f8 + (4.0/9.0)*d7*f1 + (4.0/9.0)*d7*f2 + (1.0/9.0)*d7*f3 + (1.0/9.0)*d7*f4 + (1.0/9.0)*d7*f5 + (1.0/9.0)*d7*f6 + (4.0/9.0)*d8*f1 + (4.0/9.0)*d8*f2 + (1.0/9.0)*d8*f3 + (1.0/9.0)*d8*f4 + (1.0/9.0)*d8*f5 + (1.0/9.0)*d8*f6;
 v[5]=(4.0/9.0)*d1*f3 + (4.0/9.0)*d1*f4 + (4.0/9.0)*d1*f5 + (4.0/9.0)*d1*f6 + (4.0/9.0)*d1*f7 + (4.0/9.0)*d1*f8 + (4.0/9.0)*d2*f3 + (4.0/9.0)*d2*f4 + (4.0/9.0)*d2*f5 + (4.0/9.0)*d2*f6 + (4.0/9.0)*d2*f7 + (4.0/9.0)*d2*f8 + (1.0/9.0)*d3*f1 + (1.0/9.0)*d3*f2 + (1.0/9.0)*d3*f5 + (1.0/9.0)*d3*f6 + (1.0/9.0)*d3*f7 + (1.0/9.0)*d3*f8 + (1.0/9.0)*d4*f1 + (1.0/9.0)*d4*f2 + (1.0/9.0)*d4*f5 + (1.0/9.0)*d4*f6 + (1.0/9.0)*d4*f7 + (1.0/9.0)*d4*f8 + (1.0/9.0)*d5*f1 + (1.0/9.0)*d5*f2 + (1.0/9.0)*d5*f3 + (1.0/9.0)*d5*f4 + (1.0/9.0)*d5*f7 + (1.0/9.0)*d5*f8 + (1.0/9.0)*d6*f1 + (1.0/9.0)*d6*f2 + (1.0/9.0)*d6*f3 + (1.0/9.0)*d6*f4 + (1.0/9.0)*d6*f7 + (1.0/9.0)*d6*f8 + (4.0/9.0)*d7*f1 + (4.0/9.0)*d7*f2 + (4.0/9.0)*d7*f3 + (4.0/9.0)*d7*f4 + (4.0/9.0)*d7*f5 + (4.0/9.0)*d7*f6 + (4.0/9.0)*d8*f1 + (4.0/9.0)*d8*f2 + (4.0/9.0)*d8*f3 + (4.0/9.0)*d8*f4 + (4.0/9.0)*d8*f5 + (4.0/9.0)*d8*f6;
 v[6]=-2.0/9.0*d1*f3 + (2.0/9.0)*d1*f4 - 2.0/9.0*d1*f5 + (2.0/9.0)*d1*f6 + (4.0/9.0)*d1*f7 - 4.0/9.0*d1*f8 + (2.0/9.0)*d2*f3 - 2.0/9.0*d2*f4 + (2.0/9.0)*d2*f5 - 2.0/9.0*d2*f6 - 4.0/9.0*d2*f7 + (4.0/9.0)*d2*f8 - 2.0/9.0*d3*f1 + (2.0/9.0)*d3*f2 + (1.0/9.0)*d3*f5 - 1.0/9.0*d3*f6 - 2.0/9.0*d3*f7 + (2.0/9.0)*d3*f8 + (2.0/9.0)*d4*f1 - 2.0/9.0*d4*f2 - 1.0/9.0*d4*f5 + (1.0/9.0)*d4*f6 + (2.0/9.0)*d4*f7 - 2.0/9.0*d4*f8 - 2.0/9.0*d5*f1 + (2.0/9.0)*d5*f2 + (1.0/9.0)*d5*f3 - 1.0/9.0*d5*f4 - 2.0/9.0*d5*f7 + (2.0/9.0)*d5*f8 + (2.0/9.0)*d6*f1 - 2.0/9.0*d6*f2 - 1.0/9.0*d6*f3 + (1.0/9.0)*d6*f4 + (2.0/9.0)*d6*f7 - 2.0/9.0*d6*f8 + (4.0/9.0)*d7*f1 - 4.0/9.0*d7*f2 - 2.0/9.0*d7*f3 + (2.0/9.0)*d7*f4 - 2.0/9.0*d7*f5 + (2.0/9.0)*d7*f6 - 4.0/9.0*d8*f1 + (4.0/9.0)*d8*f2 + (2.0/9.0)*d8*f3 - 2.0/9.0*d8*f4 + (2.0/9.0)*d8*f5 - 2.0/9.0*d8*f6;
 v[7]=f0*((4.0/9.0)*d1 + (4.0/9.0)*d2 + (1.0/9.0)*d3 + (1.0/9.0)*d4 + (1.0/9.0)*d5 + (1.0/9.0)*d6 + (4.0/9.0)*d7 + (4.0/9.0)*d8);
 v[8]=d0*((4.0/9.0)*f1 + (4.0/9.0)*f2 + (1.0/9.0)*f3 + (1.0/9.0)*f4 + (1.0/9.0)*f5 + (1.0/9.0)*f6 + (4.0/9.0)*f7 + (4.0/9.0)*f8);
 charges[0][0]=2.0/3.0;charges[0][1]=0;charges[0][2]=2.0/3.0;charges[0][3]=0;
 charges[1][0]=-1.0/3.0;charges[1][1]=1;charges[1][2]=1;charges[1][3]=0;}else if(nf==5){ v[0]=d1*f1 + d2*f2 + d7*f7 + d8*f8;
 v[1]=d10*f10 + d3*f3 + d4*f4 + d5*f5 + d6*f6 + d9*f9;
 v[2]=(11.0/9.0)*d0*f0;
 v[3]=(4.0/9.0)*d1*f2 + (1.0/9.0)*d10*f9 + (4.0/9.0)*d2*f1 + (1.0/9.0)*d3*f4 + (1.0/9.0)*d4*f3 + (1.0/9.0)*d5*f6 + (1.0/9.0)*d6*f5 + (4.0/9.0)*d7*f8 + (4.0/9.0)*d8*f7 + (1.0/9.0)*d9*f10;
 v[4]=(1.0/9.0)*d1*f10 + (1.0/9.0)*d1*f3 + (1.0/9.0)*d1*f4 + (1.0/9.0)*d1*f5 + (1.0/9.0)*d1*f6 + (4.0/9.0)*d1*f7 + (4.0/9.0)*d1*f8 + (1.0/9.0)*d1*f9 + (4.0/9.0)*d10*f1 + (4.0/9.0)*d10*f2 + (1.0/9.0)*d10*f3 + (1.0/9.0)*d10*f4 + (1.0/9.0)*d10*f5 + (1.0/9.0)*d10*f6 + (4.0/9.0)*d10*f7 + (4.0/9.0)*d10*f8 + (1.0/9.0)*d2*f10 + (1.0/9.0)*d2*f3 + (1.0/9.0)*d2*f4 + (1.0/9.0)*d2*f5 + (1.0/9.0)*d2*f6 + (4.0/9.0)*d2*f7 + (4.0/9.0)*d2*f8 + (1.0/9.0)*d2*f9 + (4.0/9.0)*d3*f1 + (1.0/9.0)*d3*f10 + (4.0/9.0)*d3*f2 + (1.0/9.0)*d3*f5 + (1.0/9.0)*d3*f6 + (4.0/9.0)*d3*f7 + (4.0/9.0)*d3*f8 + (1.0/9.0)*d3*f9 + (4.0/9.0)*d4*f1 + (1.0/9.0)*d4*f10 + (4.0/9.0)*d4*f2 + (1.0/9.0)*d4*f5 + (1.0/9.0)*d4*f6 + (4.0/9.0)*d4*f7 + (4.0/9.0)*d4*f8 + (1.0/9.0)*d4*f9 + (4.0/9.0)*d5*f1 + (1.0/9.0)*d5*f10 + (4.0/9.0)*d5*f2 + (1.0/9.0)*d5*f3 + (1.0/9.0)*d5*f4 + (4.0/9.0)*d5*f7 + (4.0/9.0)*d5*f8 + (1.0/9.0)*d5*f9 + (4.0/9.0)*d6*f1 + (1.0/9.0)*d6*f10 + (4.0/9.0)*d6*f2 + (1.0/9.0)*d6*f3 + (1.0/9.0)*d6*f4 + (4.0/9.0)*d6*f7 + (4.0/9.0)*d6*f8 + (1.0/9.0)*d6*f9 + (4.0/9.0)*d7*f1 + (1.0/9.0)*d7*f10 + (4.0/9.0)*d7*f2 + (1.0/9.0)*d7*f3 + (1.0/9.0)*d7*f4 + (1.0/9.0)*d7*f5 + (1.0/9.0)*d7*f6 + (1.0/9.0)*d7*f9 + (4.0/9.0)*d8*f1 + (1.0/9.0)*d8*f10 + (4.0/9.0)*d8*f2 + (1.0/9.0)*d8*f3 + (1.0/9.0)*d8*f4 + (1.0/9.0)*d8*f5 + (1.0/9.0)*d8*f6 + (1.0/9.0)*d8*f9 + (4.0/9.0)*d9*f1 + (4.0/9.0)*d9*f2 + (1.0/9.0)*d9*f3 + (1.0/9.0)*d9*f4 + (1.0/9.0)*d9*f5 + (1.0/9.0)*d9*f6 + (4.0/9.0)*d9*f7 + (4.0/9.0)*d9*f8;
 v[5]=(4.0/9.0)*d1*f10 + (4.0/9.0)*d1*f3 + (4.0/9.0)*d1*f4 + (4.0/9.0)*d1*f5 + (4.0/9.0)*d1*f6 + (4.0/9.0)*d1*f7 + (4.0/9.0)*d1*f8 + (4.0/9.0)*d1*f9 + (1.0/9.0)*d10*f1 + (1.0/9.0)*d10*f2 + (1.0/9.0)*d10*f3 + (1.0/9.0)*d10*f4 + (1.0/9.0)*d10*f5 + (1.0/9.0)*d10*f6 + (1.0/9.0)*d10*f7 + (1.0/9.0)*d10*f8 + (4.0/9.0)*d2*f10 + (4.0/9.0)*d2*f3 + (4.0/9.0)*d2*f4 + (4.0/9.0)*d2*f5 + (4.0/9.0)*d2*f6 + (4.0/9.0)*d2*f7 + (4.0/9.0)*d2*f8 + (4.0/9.0)*d2*f9 + (1.0/9.0)*d3*f1 + (1.0/9.0)*d3*f10 + (1.0/9.0)*d3*f2 + (1.0/9.0)*d3*f5 + (1.0/9.0)*d3*f6 + (1.0/9.0)*d3*f7 + (1.0/9.0)*d3*f8 + (1.0/9.0)*d3*f9 + (1.0/9.0)*d4*f1 + (1.0/9.0)*d4*f10 + (1.0/9.0)*d4*f2 + (1.0/9.0)*d4*f5 + (1.0/9.0)*d4*f6 + (1.0/9.0)*d4*f7 + (1.0/9.0)*d4*f8 + (1.0/9.0)*d4*f9 + (1.0/9.0)*d5*f1 + (1.0/9.0)*d5*f10 + (1.0/9.0)*d5*f2 + (1.0/9.0)*d5*f3 + (1.0/9.0)*d5*f4 + (1.0/9.0)*d5*f7 + (1.0/9.0)*d5*f8 + (1.0/9.0)*d5*f9 + (1.0/9.0)*d6*f1 + (1.0/9.0)*d6*f10 + (1.0/9.0)*d6*f2 + (1.0/9.0)*d6*f3 + (1.0/9.0)*d6*f4 + (1.0/9.0)*d6*f7 + (1.0/9.0)*d6*f8 + (1.0/9.0)*d6*f9 + (4.0/9.0)*d7*f1 + (4.0/9.0)*d7*f10 + (4.0/9.0)*d7*f2 + (4.0/9.0)*d7*f3 + (4.0/9.0)*d7*f4 + (4.0/9.0)*d7*f5 + (4.0/9.0)*d7*f6 + (4.0/9.0)*d7*f9 + (4.0/9.0)*d8*f1 + (4.0/9.0)*d8*f10 + (4.0/9.0)*d8*f2 + (4.0/9.0)*d8*f3 + (4.0/9.0)*d8*f4 + (4.0/9.0)*d8*f5 + (4.0/9.0)*d8*f6 + (4.0/9.0)*d8*f9 + (1.0/9.0)*d9*f1 + (1.0/9.0)*d9*f2 + (1.0/9.0)*d9*f3 + (1.0/9.0)*d9*f4 + (1.0/9.0)*d9*f5 + (1.0/9.0)*d9*f6 + (1.0/9.0)*d9*f7 + (1.0/9.0)*d9*f8;
 v[6]=(2.0/9.0)*d1*f10 - 2.0/9.0*d1*f3 + (2.0/9.0)*d1*f4 - 2.0/9.0*d1*f5 + (2.0/9.0)*d1*f6 + (4.0/9.0)*d1*f7 - 4.0/9.0*d1*f8 - 2.0/9.0*d1*f9 + (2.0/9.0)*d10*f1 - 2.0/9.0*d10*f2 - 1.0/9.0*d10*f3 + (1.0/9.0)*d10*f4 - 1.0/9.0*d10*f5 + (1.0/9.0)*d10*f6 + (2.0/9.0)*d10*f7 - 2.0/9.0*d10*f8 - 2.0/9.0*d2*f10 + (2.0/9.0)*d2*f3 - 2.0/9.0*d2*f4 + (2.0/9.0)*d2*f5 - 2.0/9.0*d2*f6 - 4.0/9.0*d2*f7 + (4.0/9.0)*d2*f8 + (2.0/9.0)*d2*f9 - 2.0/9.0*d3*f1 - 1.0/9.0*d3*f10 + (2.0/9.0)*d3*f2 + (1.0/9.0)*d3*f5 - 1.0/9.0*d3*f6 - 2.0/9.0*d3*f7 + (2.0/9.0)*d3*f8 + (1.0/9.0)*d3*f9 + (2.0/9.0)*d4*f1 + (1.0/9.0)*d4*f10 - 2.0/9.0*d4*f2 - 1.0/9.0*d4*f5 + (1.0/9.0)*d4*f6 + (2.0/9.0)*d4*f7 - 2.0/9.0*d4*f8 - 1.0/9.0*d4*f9 - 2.0/9.0*d5*f1 - 1.0/9.0*d5*f10 + (2.0/9.0)*d5*f2 + (1.0/9.0)*d5*f3 - 1.0/9.0*d5*f4 - 2.0/9.0*d5*f7 + (2.0/9.0)*d5*f8 + (1.0/9.0)*d5*f9 + (2.0/9.0)*d6*f1 + (1.0/9.0)*d6*f10 - 2.0/9.0*d6*f2 - 1.0/9.0*d6*f3 + (1.0/9.0)*d6*f4 + (2.0/9.0)*d6*f7 - 2.0/9.0*d6*f8 - 1.0/9.0*d6*f9 + (4.0/9.0)*d7*f1 + (2.0/9.0)*d7*f10 - 4.0/9.0*d7*f2 - 2.0/9.0*d7*f3 + (2.0/9.0)*d7*f4 - 2.0/9.0*d7*f5 + (2.0/9.0)*d7*f6 - 2.0/9.0*d7*f9 - 4.0/9.0*d8*f1 - 2.0/9.0*d8*f10 + (4.0/9.0)*d8*f2 + (2.0/9.0)*d8*f3 - 2.0/9.0*d8*f4 + (2.0/9.0)*d8*f5 - 2.0/9.0*d8*f6 + (2.0/9.0)*d8*f9 - 2.0/9.0*d9*f1 + (2.0/9.0)*d9*f2 + (1.0/9.0)*d9*f3 - 1.0/9.0*d9*f4 + (1.0/9.0)*d9*f5 - 1.0/9.0*d9*f6 - 2.0/9.0*d9*f7 + (2.0/9.0)*d9*f8;
 v[7]=f0*((4.0/9.0)*d1 + (1.0/9.0)*d10 + (4.0/9.0)*d2 + (1.0/9.0)*d3 + (1.0/9.0)*d4 + (1.0/9.0)*d5 + (1.0/9.0)*d6 + (4.0/9.0)*d7 + (4.0/9.0)*d8 + (1.0/9.0)*d9);
 v[8]=d0*((4.0/9.0)*f1 + (1.0/9.0)*f10 + (4.0/9.0)*f2 + (1.0/9.0)*f3 + (1.0/9.0)*f4 + (1.0/9.0)*f5 + (1.0/9.0)*f6 + (4.0/9.0)*f7 + (4.0/9.0)*f8 + (1.0/9.0)*f9);
 charges[0][0]=2.0/3.0;charges[0][1]=-1.0/3.0;charges[0][2]=7.0/9.0;charges[0][3]=0;
 charges[1][0]=-1.0/3.0;charges[1][1]=2.0/3.0;charges[1][2]=10.0/9.0;charges[1][3]=0;}else {throw std::runtime_error("unsupported active flavors");}
}
static void pdf(double xi,double mu2,double*f){
 if(!(xi>=1e-5 && xi<=1 && mu2>=1.25 && mu2<=1e7))throw std::runtime_error("MRST grid range");
 double raw[8];sidis_pdf(xi,sqrt(mu2),raw);const double r0=raw[0],r1=raw[1],r2=raw[2],r3=raw[3],r4=raw[4],r5=raw[5],r6=raw[6],r7=raw[7];
  f[0]=r7/xi;
 f[1]=(r0 + r2)/xi;
 f[2]=r2/xi;
 f[3]=(r1 + r3)/xi;
 f[4]=r3/xi;
 f[5]=r4/xi;
 f[6]=r4/xi;
 f[7]=r5/xi;
 f[8]=r5/xi;
 f[9]=r6/xi;
 f[10]=r6/xi;
}
static void ff(double z,double mu2,int set,double*d){
 if(!(z>=0.01 && z<=1 && mu2>=1 && mu2<=1e6))throw std::runtime_error("FF grid range");
 if(set==0)sidis_kkp(z,sqrt(mu2),5,d);
 else {sidis_kretzer(z,mu2,3,d);for(int i=0;i<11;i++)d[i]*=1.0/2.0;}
 for(int i=1;i<11;i+=2)if(std::abs(d[i]-d[i+1])>1e-12*std::max(1.,std::abs(d[i])))throw std::runtime_error("neutral FF conjugation");
}
static double acceptance(double Q2,double y,double pt,double zH){
 double Emin=0.01*Ep;
 double lo=std::max(-1.,(1.0/2.0)*(y - 1)*(4*pow(Ee, 2)*pow(y, 2)*pow(zH, 2) - 4*Ee*Emin*y*zH - Q2*y*pow(zH, 2) + Q2*pow(zH, 2) + pow(pt, 2))/(sqrt(Q2)*pt*zH*pow(1 - y, 3.0/2.0)));
 double ctheta=cos((5.0/36.0)*M_PI);
 lo=std::max(lo,-1.0/2.0*(4*pow(Ee, 2)*ctheta*pow(y, 2)*pow(zH, 2) + 4*pow(Ee, 2)*pow(y, 2)*pow(zH, 2) - Q2*ctheta*y*pow(zH, 2) + Q2*ctheta*pow(zH, 2) + Q2*y*pow(zH, 2) - Q2*pow(zH, 2) + ctheta*pow(pt, 2) - pow(pt, 2))/(sqrt(Q2)*pt*zH*sqrt(1 - y)*(ctheta - 1)));
 ctheta=cos((1.0/36.0)*M_PI);
 double hi=std::min(1.,-1.0/2.0*(4*pow(Ee, 2)*ctheta*pow(y, 2)*pow(zH, 2) + 4*pow(Ee, 2)*pow(y, 2)*pow(zH, 2) - Q2*ctheta*y*pow(zH, 2) + Q2*ctheta*pow(zH, 2) + Q2*y*pow(zH, 2) - Q2*pow(zH, 2) + ctheta*pow(pt, 2) - pow(pt, 2))/(sqrt(Q2)*pt*zH*sqrt(1 - y)*(ctheta - 1)));
 if(lo>=hi)return 0.;
 return (1.0/2.0)*(-acos(hi) + 2*M_PI)/M_PI - 1.0/2.0*(-acos(lo) + 2*M_PI)/M_PI - 1.0/2.0*acos(hi)/M_PI + (1.0/2.0)*acos(lo)/M_PI;
}
extern "C" int sidis_init(){
 try{if(initialized)return 0;std::fill(&ids[0][0][0],&ids[0][0][0]+6*8*3,-1);
 ids[0][0][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqq_LODelta_1.dat");included[0][0]=false;
ids[0][1][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqq_Delta_1.dat");included[0][1]=false;
ids[0][2][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqq_L0_1.dat");included[0][2]=false;
ids[0][3][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqq_L1_1.dat");included[0][3]=false;
ids[0][4][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqq_Regular_1.dat");included[0][4]=false;
ids[0][0][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqq_LODelta_m1.dat");included[0][0]=false;
ids[0][1][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqq_Delta_m1.dat");included[0][1]=false;
ids[0][2][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqq_L0_m1.dat");included[0][2]=false;
ids[0][3][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqq_L1_m1.dat");included[0][3]=false;
ids[0][4][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqq_Regular_m1.dat");included[0][4]=false;
ids[0][0][2]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqq_LODelta_0.dat");included[0][0]=false;
ids[0][1][2]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqq_Delta_0.dat");included[0][1]=false;
ids[0][2][2]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqq_L0_0.dat");included[0][2]=false;
ids[0][3][2]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqq_L1_0.dat");included[0][3]=false;
ids[0][4][2]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqq_Regular_0.dat");included[0][4]=false;
ids[1][4][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgg_Regular_1.dat");included[1][4]=false;
ids[1][4][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgg_Regular_m1.dat");included[1][4]=false;
ids[2][4][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqqbar_Regular_1.dat");included[2][4]=false;
ids[2][4][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqqbar_Regular_m1.dat");included[2][4]=false;
ids[3][6][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqqprime_PrimeChargeSquared_Regular_1.dat");included[3][6]=false;
ids[3][6][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqqprime_PrimeChargeSquared_Regular_m1.dat");included[3][6]=false;
ids[3][7][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqqprime_MixedIncomingPrimeCharge_Regular_1.dat");included[3][7]=false;
ids[3][7][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqqprime_MixedIncomingPrimeCharge_Regular_m1.dat");included[3][7]=false;
ids[3][5][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqqprime_IncomingChargeSquared_Regular_1.dat");included[3][5]=false;
ids[3][5][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqqprime_IncomingChargeSquared_Regular_m1.dat");included[3][5]=false;
ids[4][0][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgq_LODelta_1.dat");included[4][0]=false;
ids[4][1][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgq_Delta_1.dat");included[4][1]=false;
ids[4][2][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgq_L0_1.dat");included[4][2]=false;
ids[4][3][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgq_L1_1.dat");included[4][3]=false;
ids[4][4][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgq_Regular_1.dat");included[4][4]=false;
ids[4][0][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgq_LODelta_m1.dat");included[4][0]=false;
ids[4][1][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgq_Delta_m1.dat");included[4][1]=false;
ids[4][2][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgq_L0_m1.dat");included[4][2]=false;
ids[4][3][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgq_L1_m1.dat");included[4][3]=false;
ids[4][4][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgq_Regular_m1.dat");included[4][4]=false;
ids[4][0][2]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgq_LODelta_0.dat");included[4][0]=false;
ids[4][1][2]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgq_Delta_0.dat");included[4][1]=false;
ids[4][2][2]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgq_L0_0.dat");included[4][2]=false;
ids[4][3][2]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgq_L1_0.dat");included[4][3]=false;
ids[4][4][2]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hgq_Regular_0.dat");included[4][4]=false;
ids[5][0][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqg_LODelta_1.dat");included[5][0]=false;
ids[5][1][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqg_Delta_1.dat");included[5][1]=false;
ids[5][2][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqg_L0_1.dat");included[5][2]=false;
ids[5][3][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqg_L1_1.dat");included[5][3]=false;
ids[5][4][1]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqg_Regular_1.dat");included[5][4]=false;
ids[5][0][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqg_LODelta_m1.dat");included[5][0]=false;
ids[5][1][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqg_Delta_m1.dat");included[5][1]=false;
ids[5][2][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqg_L0_m1.dat");included[5][2]=false;
ids[5][3][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqg_L1_m1.dat");included[5][3]=false;
ids[5][4][0]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqg_Regular_m1.dat");included[5][4]=false;
ids[5][0][2]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqg_LODelta_0.dat");included[5][0]=false;
ids[5][1][2]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqg_Delta_0.dat");included[5][1]=false;
ids[5][2][2]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqg_L0_0.dat");included[5][2]=false;
ids[5][3][2]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqg_L1_0.dat");included[5][3]=false;
ids[5][4][2]=sidis_load_program("/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/numerics/s07_cache/s07_pair_Hqg_Regular_0.dat");included[5][4]=false;
 sidis_set_alpha(2.045,18.5,0.1085488995978293);initialized=true;return 0;
 }catch(...){return 1;}
}
extern "C" const char* sidis_error(){return failure.c_str();}
struct Point{
 double Q2,y,pt,zH,xi,ss,B,mu2,zeta,J,s,t,w1,w2,args[19];int nf,branch;
 Point(double Q,double yy,double pp,double z,double xx,double recoil):Q2(Q),y(yy),pt(pp),zH(z),xi(xx),ss(recoil){
  B=map_B(Q2,y,pt,zH,xi,ss);mu2=map_mu2(Q2,y,pt,zH,xi,ss);
  zeta=map_zeta(Q2,y,pt,zH,xi,ss);J=map_jacobian(Q2,y,pt,zH,xi,ss);
  s=map_s(Q2,y,pt,zH,xi,ss);t=map_t(Q2,y,pt,zH,xi,ss);
  nf=mu2<18.5?4:5;branch=s+t>0;
  if(!(s>0 && t<0 && B>0 && zeta>0 && zeta<1 && J>0 && mu2>2.045))throw std::runtime_error("partonic map domain");
  w1=map_sigma_weight_F1(Q2,y,pt,zH,xi,ss)/xi;
  w2=map_sigma_weight_F2(Q2,y,pt,zH,xi,ss);
  const double a[]={Q2,s,t,ss,B,mu2,map_xHat(Q2,y,pt,zH,xi,ss),zH,pt*pt,map_xB(Q2,y,pt,zH,xi,ss),xi,sidis_alpha(mu2),1,1,0,0,double(nf),1,std::abs(s+t)};
  std::copy(a,a+19,args);
 }
 double coefficient(int ch,int label,const double*charge=nullptr){
  int routed=(s+t==0 && (ch==4 || ch==5 || ch==0))?2:branch;
  int id=ids[ch][label][routed];if(id<0)throw std::runtime_error("missing hard function");
  if(charge)std::copy(charge,charge+4,args+12);else {args[12]=args[13]=1;args[14]=args[15]=0;}
  double out[3];int status=sidis_eval(id,args,out);
  if(status){std::ostringstream os;os<<"hard function status="<<status<<" channel="<<ch<<" label="<<label<<" branch="<<branch<<" output="<<out[0]<<","<<out[1]<<","<<out[2]<<" args=";os.precision(17);for(auto v:args)os<<v<<",";throw std::runtime_error(os.str());}
  return (out[0]*w1+out[1]*w2)*(included[ch][label]?1.:J)/(zeta*zeta);
 }
};
extern "C" int sidis_integrand(const double*unit,const double*bounds,double*out,double*diagnostics){
 try{
  std::fill(out,out+24,0.);std::fill(diagnostics,diagnostics+10,0.);
  double jq,jy,jp,jz,jxi,jss;
  double Q2=logmap(unit[0],bounds[0],bounds[1],jq),y=linmap(unit[1],bounds[2],bounds[3],jy),pt=logmap(unit[2],bounds[4],bounds[5],jp);
  double zl=map_z_lower(Q2,y,pt,0,0,0),zh=map_z_upper(Q2,y,pt,0,0,0);
  if(!(std::isfinite(zl)&&zl>0&&zh>zl&&zh<1))throw std::runtime_error("hadron z bounds");
  double zH=logmap(unit[3],zl,zh,jz);
  double acc=acceptance(Q2,y,pt,zH);diagnostics[0]=acc;
  if(acc==0)return 0;
  double xmin=map_xi_min(Q2,y,pt,zH,0,0);
  double xi=logmap(unit[4],xmin,1.,jxi),B=map_B(Q2,y,pt,zH,xi,0);
  double ss=linmap(unit[5],0.,B,jss);
  Point end(Q2,y,pt,zH,xi,0),cur(Q2,y,pt,zH,xi,ss);
  double weight=jq*jy*jp*jz*jxi*acc*pb;
  diagnostics[1]=xi;diagnostics[2]=end.zeta;diagnostics[3]=cur.zeta;
  diagnostics[4]=Q2;diagnostics[5]=y;diagnostics[6]=pt;diagnostics[7]=zH;diagnostics[8]=ss;diagnostics[9]=B;
  double f[11],d[11],lum[2][2][9],charges[2][4];pdf(xi,end.mu2,f);
  for(int set=0;set<2;set++)for(int pos=0;pos<2;pos++){
   ff(pos?cur.zeta:end.zeta,end.mu2,set,d);luminosity(end.nf,f,d,lum[set][pos],charges);
   if(std::abs(lum[set][pos][6])>1e-10*std::max(1.,std::abs(lum[set][pos][4])))throw std::runtime_error("prime interference identity");
  }
  for(int ch=0;ch<6;ch++){
   if(!(channelMask&(1u<<ch)))continue;
   if(ch==1||ch==2||ch==3){
    if(ch==3){for(int basis=0;basis<2;basis++){
     double h=cur.coefficient(ch,5+basis);
     for(int set=0;set<2;set++)out[set*12+ch*2+1]+=h*lum[set][1][4+basis]*jss*weight;
    }}else {
     double h=cur.coefficient(ch,4);int which=ch+1;
     for(int set=0;set<2;set++)out[set*12+ch*2+1]=h*lum[set][1][which]*jss*weight;
    }
    continue;
   }
   for(int group=0;group<(ch==0?2:1);group++){
    const double*charge=ch==0?charges[group]:nullptr;
    int which=ch==0?group:ch+3;
    double born=end.coefficient(ch,0,charge),delta=end.coefficient(ch,1,charge),reg=cur.coefficient(ch,4,charge);
    double p0=end.coefficient(ch,2,charge),p1=cur.coefficient(ch,2,charge);
    double l0=end.coefficient(ch,3,charge),l1=cur.coefficient(ch,3,charge);
    double logarithm=plusLogarithm(ch,ss,B);
    for(int set=0;set<2;set++){
     double e=lum[set][0][which],c=lum[set][1][which];
     out[set*12+ch*2]+=born*e*weight;
     out[set*12+ch*2+1]+=(delta*e+(reg*c+(p1*c-p0*e)/ss+(l1*c-l0*e)*logarithm/ss)*jss)*weight;
    }
   }
  }
  for(int i=0;i<24;i++)if(!std::isfinite(out[i]))throw std::runtime_error("nonfinite convolution");
  return 0;
 }catch(const std::exception&e){failure=e.what();return 1;}
}
