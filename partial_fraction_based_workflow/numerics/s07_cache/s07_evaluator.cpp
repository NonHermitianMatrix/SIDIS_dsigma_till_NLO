
#include <boost/multiprecision/cpp_complex.hpp>
#include <cmath>
#include <vector>
#include <array>
#include <string>
#include <sstream>
#include <fstream>
#include <algorithm>
#include <stdexcept>
#include <limits>
#include <cstdint>
using Z=boost::multiprecision::cpp_complex_100;
using R=boost::multiprecision::cpp_bin_float_100;
struct Op {int op,a,b;};
struct V {Z value;int jet;V(Z x=0,int j=-1):value(x),jet(j){} };
struct Program {
 std::vector<Op> ops;std::vector<Z> constants;std::vector<V> values;std::vector<uint32_t> dependencies;
 std::array<double,19> previous{};bool valid=false;int result,sign;
};
static std::vector<Program> programs;
using DilogCallback=int(*)(const char*,const char*,char*,char*,size_t);
static DilogCallback dilog_callback=nullptr;
extern "C" void sidis_set_dilog(DilogCallback f){dilog_callback=f;}
static thread_local std::vector<std::array<Z,2>> jets;
static Z principal(const Z&x){return x.imag()==0?Z(x.real(),R(0)):x;}
static Z product(const Z&x,const Z&y){return x.imag()==0&&y.imag()==0?Z(R(x.real()*y.real())):Z(x*y);}
static Z quotient(const Z&x,const Z&y){return x.imag()==0&&y.imag()==0?Z(R(x.real()/y.real())):Z(x/y);}
static Z coeff(const V&v,int degree){return degree==0?v.value:(v.jet<0?Z(0):jets[v.jet][degree-1]);}
static V with_jet(Z x,Z c1,Z c2){
 if(c1==0&&c2==0)return V(x);
 int index=jets.size();jets.push_back({c1,c2});return V(x,index);
}
static V multiply(const V&a,const V&b){
 if(a.jet<0&&b.jet<0)return V(product(a.value,b.value));
 Z c[3]={0,0,0};
 for(int i=0;i<3;i++)for(int j=0;j<3;j++){
  Z term=coeff(a,i)*coeff(b,j);
  if(i+j<3)c[i+j]+=term;else if(term!=0)throw std::runtime_error("singular-log degree");
 }return with_jet(c[0],c[1],c[2]);
}
static Z ipow(Z x,int n){
 if(x.imag()==0)return Z(R(pow(x.real(),n)));
 if(n<0)return Z(1)/ipow(x,-n);
 Z value=1;while(n){if(n&1)value*=x;n>>=1;if(n)x*=x;}return value;
}
static Z dilog(const Z&a){
 if(!dilog_callback)throw std::runtime_error("missing arbitrary-precision dilogarithm callback");
 std::string re=a.real().str(108,std::ios_base::scientific),im=a.imag().str(108,std::ios_base::scientific);
 char outr[256],outi[256];
 if(dilog_callback(re.c_str(),im.c_str(),outr,outi,sizeof(outr)))throw std::runtime_error("dilog callback");
 return Z(R(outr),R(outi));
}
extern "C" int sidis_load_program(const char*path){
 try{
  std::ifstream in(path,std::ios::binary);int h[5];in.read((char*)h,sizeof(h));
  if(!in||h[0]<1||h[0]>2000000||h[1]<1||h[4]<1||h[4]>10000000)return -1;
  Program p;p.result=h[2];p.sign=h[3];std::string text(h[4],'\0');in.read(text.data(),h[4]);
  std::istringstream stream(text);std::string s;
  for(int i=0;i<h[1];i++){
   std::getline(stream,s);
   if(s=="Pi")s="3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865";
   else if(s=="EulerGamma")s="0.57721566490153286060651209008240243104215933593992359880576723488486772677766467093694706329174674951463144725";
   else if(s=="E")s="2.7182818284590452353602874713526624977572470936999595749669676277240766303535475945713821785251664274274663919";
   p.constants.emplace_back(R(s));
  }
  p.ops.resize(h[0]);in.read((char*)p.ops.data(),sizeof(Op)*h[0]);if(!in)return -1;
  for(size_t n=0;n<p.ops.size();n++){
   const auto&o=p.ops[n];uint32_t mask=0;
   if(o.op==1){if(o.a<0||o.a>=19)return -1;mask=uint32_t(1)<<o.a;}
   else if(o.op!=0){if(o.a<0||o.a>=int(n)||o.b>=int(n))return -1;mask=p.dependencies[o.a];if(o.b>=0)mask|=p.dependencies[o.b];}
   p.dependencies.push_back(mask);
  }
  programs.push_back(std::move(p));return programs.size()-1;
 }catch(...){return -1;}
}
extern "C" int sidis_eval(int id,const double*input,double*output){
 try{
  auto&p=programs.at(id);auto&v=p.values;v.resize(p.ops.size());jets.clear();
  uint32_t changed=0;for(size_t j=0;j<p.previous.size();j++)if(input[j]!=p.previous[j])changed|=uint32_t(1)<<j;
  bool reusable=p.valid;p.valid=false;
  for(size_t n=0;n<p.ops.size();n++){
   if(reusable && !(p.dependencies[n]&changed))continue;
   const Op&o=p.ops[n];V r;
   if(o.op==0)r=V(p.constants[o.a]);
   else if(o.op==1)r=V(Z(R(input[o.a])));
   else{
    const V&a=v[o.a];const V&b=o.b>=0?v[o.b]:a;
    const Z&x=a.value;const Z&y=b.value;
    if(o.op==2||o.op==3){
     if(a.jet<0&&b.jet<0)r=V(o.op==2?Z(x+y):Z(x-y));
     else if(o.op==2)r=with_jet(x+y,coeff(a,1)+coeff(b,1),coeff(a,2)+coeff(b,2));
     else r=with_jet(x-y,coeff(a,1)-coeff(b,1),coeff(a,2)-coeff(b,2));
    }
    else if(o.op==4)r=multiply(a,b);
    else if(o.op==5){if(b.jet>=0)throw std::runtime_error("log denominator");r=a.jet<0?V(quotient(x,y)):with_jet(x/y,coeff(a,1)/y,coeff(a,2)/y);}
    else if(o.op==7)r=a.jet<0?V(-x):with_jet(-x,-coeff(a,1),-coeff(a,2));
    else if(o.op==22)r=a.jet<0&&b.jet<0?V(Z(x.real(),y.real())):with_jet(Z(x.real(),y.real()),Z(abs(coeff(a,1)),abs(coeff(b,1))),Z(abs(coeff(a,2)),abs(coeff(b,2))));
    else if(o.op==6&&a.jet>=0){
      if(b.jet>=0||y.imag()!=0||y.real()<0||y.real()>2||y.real()!=floor(y.real()))throw std::runtime_error("log power");
      r=V(1);for(int j=0;j<y.real().convert_to<int>();j++)r=multiply(r,a);
    }else {
     if(a.jet>=0||(o.b>=0&&b.jet>=0))throw std::runtime_error("nonlinear singular log");
     switch(o.op){
      case 6:if(y.imag()==0&&abs(y.real())<100&&y.real()==floor(y.real()))r=V(ipow(x,y.real().convert_to<int>()));else r=V(pow(principal(x),principal(y)));break;
      case 8:if(x==0)r=with_jet(0,1,0);else r=V(log(principal(x)));break;
      case 9:r=V(sqrt(principal(x)));break;
      case 10:if(x!=2)throw std::runtime_error("polylog order");r=V(dilog(y));break;
      case 11:{Z w=dilog(x);if(x.imag()==0&&x.real()>1)w=Z(w.real(),R(abs(w.imag())*p.sign*(y.real()>0?1:-1)));r=V(w);break;}
      case 12:r=V(x.real());break;case 13:r=V(x.imag());break;
      case 14:r=V(abs(x));break;case 15:r=V(conj(x));break;
      case 16:case 17:case 18:throw std::runtime_error("unexpanded elementary function");
      case 19:r=V(exp(x));break;
      case 20:r=V(Z(x.real(),y.real()));break;
      case 21:if(x.imag()!=0||y.imag()!=0)throw std::runtime_error("complex atan2");r=V(atan2(y.real()==0?R(0):R(y.real()),x.real()==0?R(0):R(x.real())));break;
      default:throw std::runtime_error("opcode");
     }
    }
   }v[n]=r;
  }
  const V&r=v[p.result];output[0]=r.value.real().convert_to<double>();output[1]=r.value.imag().convert_to<double>();
  R residual=std::max(R(abs(coeff(r,1))),R(abs(coeff(r,2))));output[2]=residual.convert_to<double>();
  if(!std::isfinite(output[0])||!std::isfinite(output[1])||residual>R("1e-50")*std::max(R(1),R(abs(r.value))))return 1;
  std::copy(input,input+p.previous.size(),p.previous.begin());p.valid=jets.empty();
  return 0;
 }catch(...){output[0]=output[1]=NAN;output[2]=INFINITY;return 2;}
}
