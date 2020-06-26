#include <cstddef>

#include <gmpxx.h>
#include <nfl.hpp>
#include <armadillo>


#include "utils.h"
#include "math.h"
#include <fstream>
#include <time.h>

#define THREADS 40    // for parallel processing. this is not important
#define NUM_PRIME 6   // Numper of plaintext modulus for q=q0*q1*..*q5
#define NUM_PRIME_EXT 13  // Numper of plaintext modulus for Q=q0*q1*...*q12; Q>4096*q^2
#define t 33      // plaintext modulus

#include "aws/main.c"
#include "aws/hw_interface.c"
#include "aws/poly_functions.h"
#include "aws/primitive_root.c"
#include "aws/Gaussian_sampler.c"
#include "aws/basic_ntt_large.c"
#include "aws/homomorphic_functions.c"



/// include the FV homomorphic encryption library
namespace FV {
namespace params {
//ciphertext modulus
using poly_t = nfl::poly_from_modulus<uint32_t, 1 << 12, 180>;
//plaintext modulus
template <typename T>
struct plaintextModulus;
template <>
struct plaintextModulus<mpz_class> {
  static mpz_class value_mpz;
  static unsigned long bits_in_moduli_product;
  static mpz_class product_mpz;
  static mpz_class value() {return value_mpz;}
  static mpz_class product() { return product_mpz;} 
  static void reset() {value_mpz = product();}
};

//noise with the standard deviation 
using gauss_struct = nfl::gaussian<uint16_t, uint32_t, 2>;
using gauss_t = nfl::FastGaussianNoise<uint16_t, uint32_t, 2>;
gauss_t fg_prng_sk(102.0, 80, 1 << 12);
gauss_t fg_prng_evk(102.0, 80, 1 << 12);
gauss_t fg_prng_pk(102.0, 80, 1 << 12);
gauss_t fg_prng_enc(102.0, 80, 1 << 12);
}
}  // namespace FV::params
#include "FV.hpp"

using namespace FV;

//plaintext modulus initialisation
//mpz_class params::plaintextModulus<mpz_class>::value_mpz = mpz_class("2305567963945518424753102147331756070");
//unsigned long params::plaintextModulus<mpz_class>::bits_in_moduli_product = 121;
//const size_t plaintextModuli[25] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97};

const size_t nPltxtModuli = 1; //13;
const char* plaintextModuli[nPltxtModuli] = {"33"}; //{"269", "271", "277", "281", "283", "285", "286", "287", "289", "293", "307", "311", "313"};
mpz_class params::plaintextModulus<mpz_class>::value_mpz = mpz_class("33"); //mpz_class("95059483533087812461171515276210");
mpz_class params::plaintextModulus<mpz_class>::product_mpz = mpz_class("33"); //mpz_class("95059483533087812461171515276210");
unsigned long params::plaintextModulus<mpz_class>::bits_in_moduli_product = 6; //107;

long long int q_factors[6] = {1068564481, 1069219841, 1070727169, 1071513601, 1072496641, 1073479681};

int nWindow = 2;
size_t cut_point = 385;
size_t cut_point_init = 2048;
double scalar = 1.0;

//new bases satisfying x^(w+1) - x^w - x - 1
double get_base(int nWindow)
  {
    
    if (nWindow == 1) //balanced ternary
      return 3.0;

    /*
    if (nWindow == 2) //NAF
      return 2.0;
    */

    //w-NIBNAF 1 to 10
    {
      if (nWindow == 2)
        return 1.8392867552141611325518525646532866004241787460976;

      if (nWindow == 3)
        return 1.6180339887498948482045868343656381177203091798058;

      if (nWindow == 4)
        return 1.4970940487627966489512130973325937490728546766869;

      if (nWindow == 5)
        return 1.4196327628229445453504082292735940219073674584302;

      if (nWindow == 6)
        return 1.3652547066198611671464498103655204758472477135513;

      if (nWindow == 7)
        return 1.3247179572447460259609088544780973407344040569017;

      if (nWindow == 8)
        return 1.2931880356431841941707667071685055909483716918496;

      if (nWindow == 9)
        return 1.2678747746500370400017559167241184676895964302182;

      if (nWindow == 10)
        return 1.2470478623827932649094238570056113971385190030591;
    }

    //w-NIBNAF 11 to 100
    {
      if (nWindow == 11)
        return 1.2295736071100086329887386204121888679687037670927;

      if (nWindow == 12)
        return 1.2146762120476157129198636059193192938594588768164;

      if (nWindow == 13)
        return 1.2018057285163738528520906252419881981195398056701;

      if (nWindow == 14)
        return 1.1905607496486082713018303653703967801857755824448;

      if (nWindow == 15)
        return 1.1806409911774026481504448588913502216577441979741;

      if (nWindow == 16)
        return 1.1718170471523075566771663052212383397216962084694;

      if (nWindow == 17)
        return 1.1639104494162406336126941752042207599347724717665;

      if (nWindow == 18)
        return 1.1567801397580809986131240703127383025253262481968;

      if (nWindow == 19)
        return 1.1503130616325995993026690082133373527130019041142;

      if (nWindow == 20)
        return 1.1444174725832161626875846283466857591506934154418;

      if (nWindow == 21)
        return 1.1390180978367039311061050513541557267654562620474;

      if (nWindow == 22)
        return 1.1340525571155748015425550211963430520246532358660;

      if (nWindow == 23)
        return 1.1294686891043132405390856649505389694782148004453;

      if (nWindow == 24)
        return 1.1252225198891815600034632458396451135471924297708;

      if (nWindow == 25)
        return 1.1212767007055639871629649459455138969099749818720;

      if (nWindow == 26)
        return 1.1175992926254076373185944258471520189189579833838;

      if (nWindow == 27)
        return 1.1141628110919165564713213821269592747564884588843;

      if (nWindow == 28)
        return 1.1109434674132254722845602394565531011358431290242;

      if (nWindow == 29)
        return 1.1079205611987054156733035059349058495250568866966;

      if (nWindow == 30)
        return 1.1050759896534704914828437035174681978163852172157;

      if (nWindow == 31)
        return 1.1023938481982226935834400582367270444653255359008;

      if (nWindow == 32)
        return 1.0998601030865190901488708868155197744763125360584;

      if (nWindow == 33)
        return 1.0974623212456344568114674971201853707406720244621;

      if (nWindow == 34)
        return 1.0951894459454329668968376980462752229161599569424;

      if (nWindow == 35)
        return 1.0930316094306794118473936206486052467737901142121;

      if (nWindow == 36)
        return 1.0909799755661898972865248945852075581009024451312;
      
      if (nWindow == 37)
        return 1.0890266070042362704881318175355130756487525189390;

      if (nWindow == 38)
        return 1.0871643525064931522699464569032511818713235312984;

      if (nWindow == 39)
        return 1.0853867509230741140012743575970770458849292867892;

      if (nWindow == 40)
        return 1.0836879490105876789251155390977031736531038710385;

      if (nWindow == 41)
        return 1.0820626308051650089830897336686905975127094771450;

      if (nWindow == 42)
        return 1.0805059566889007177981902046073533593839033502744;

      if (nWindow == 43)
        return 1.0790135106244581514599317979091616322143887074312;

      if (nWindow == 44)
        return 1.0775812543018633508928058659218478176294808217915;

      if (nWindow == 45)
        return 1.0762054871583064426826478257156313731511473873510;

      if (nWindow == 46)
        return 1.0748828114072338403878740559132235982405408440652;

      if (nWindow == 47)
        return 1.0736101013557421173242037011146471806122586719155;

      if (nWindow == 48)
        return 1.0723844764059388089235768726602724684080573605880;

      if (nWindow == 49)
        return 1.0712032772317156316008578877038328699844811722388;

      if (nWindow == 50)
        return 1.0700640447013644706333800260072570977350330962720;

      if (nWindow == 51)
        return 1.0689645011818732925166981592649414599744885595665;

      if (nWindow == 52)
        return 1.0679025339151187378061126877148759562900707005554;

      if (nWindow == 53)
        return 1.0668761802015570108952286273234822652588301542193;

      if (nWindow == 54)
        return 1.0658836141650318865155303354023270361432918090447;

      if(nWindow == 55)
        return 1.0649231349042766706356389432046818667090248597406;

      if(nWindow == 56)
        return 1.0639931558636426215882765423529878718023906341811;
      
      if(nWindow == 57)
        return 1.0630921952783968216570508515097669203481628264943;
      
      if(nWindow == 58)
        return 1.0622188675692958083119878563537629378789560448259;
      
      if(nWindow == 59)
        return 1.0613718755776280480104437706097108739635137944843;
      
      if(nWindow == 60)
        return 1.0605500035459967772616084987669367835986122487804;
      
      if(nWindow == 61)
        return 1.0597521107621704105673857853470305046522202507455;
      
      if(nWindow == 62)
        return 1.0589771257936792284736230780338842254701477332678;
      
      if(nWindow == 63)
        return 1.0582240412497485658018116853846982707904424110643;
      
      if(nWindow == 64)
        return 1.0574919090148499361768692902607214518583741005703;
      
      if(nWindow == 65)
        return 1.0567798359048057771819532594078426816706611594270;
      
      if(nWindow == 66)
        return 1.0560869797021541996385404859585295082582992589701;
      
      if(nWindow == 67)
        return 1.0554125455324960414098513039801597889592206209498;
      
      if(nWindow == 68)
        return 1.0547557825479160414751180280552090628615859612300;
      
      if(nWindow == 69)
        return 1.0541159808873845349967671477462470620426734057202;
      
      if(nWindow == 70)
        return 1.0534924688873831287312278462496847139420104205103;
      
      if(nWindow == 71)
        return 1.0528846105189230165477906339099148500819293739834;
      
      if(nWindow == 72)
        return 1.0522918030296937871056012335913759608378266319024;
      
      if(nWindow == 73)
        return 1.0517134747723413743707651258736424662698295590868;
      
      if(nWindow == 74)
        return 1.0511490832018668949138902751972394286036740594394;
      
      if(nWindow == 75)
        return 1.0505981130268983524239653297882293653946042816551;
      
      if(nWindow == 76)
        return 1.0500600745011444825581220680601080667537795398004;
      
      if(nWindow == 77)
        return 1.0495345018427200915381005422467905913268829810698;
      
      if(nWindow == 78)
        return 1.0490209517702572903937384679485953360119688648475;
      
      if(nWindow == 79)
        return 1.0485190021458062019887408790551133500863805324761;
      
      if(nWindow == 80)
        return 1.0480282507154986008552796945121264038447575968988;
      
      if(nWindow == 81)
        return 1.0475483139398129140559519452232999110041756012404;
      
      if(nWindow == 82)
        return 1.0470788259060515552523553870669032437210620450187;
      
      if(nWindow == 83)
        return 1.0466194373163325546579474481046989704095565996424;
      
      if(nWindow == 84)
        return 1.0461698145450163624894212951029446866587237686034;
      
      if(nWindow == 85)
        return 1.0457296387600438207045902923405073352826152053866;
      
      if(nWindow == 86)
        return 1.0452986051031598590789909225681976644747047759591;
      
      if(nWindow == 87)
        return 1.0448764219244458230069835603233979416898643808810;
      
      if(nWindow == 88)
        return 1.0444628100669870516749535605290037867219037178514;
      
      if(nWindow == 89)
        return 1.0440575021978662927629217690620088667895841956651;
      
      if(nWindow == 90)
        return 1.0436602421820020743965976843635199297042685476647;
      
      if(nWindow == 91)
        return 1.0432707844956480576806589181887505757910248197611;
      
      if(nWindow == 92)
        return 1.0428888936766380201420180055786055591309635442539;
      
      if(nWindow == 93)
        return 1.0425143438087044397437498036014050022150840948030;
      
      if(nWindow == 94)
        return 1.0421469180374192889416741909421229772181216938142;
      
      if(nWindow == 95)
        return 1.0417864081155059389651163040230755998480399741647;
      
      if(nWindow == 96)
        return 1.0414326139754530852822641801944039873617921374426;
      
      if(nWindow == 97)
        return 1.0410853433275271756615689083498186489442866497419;
      
      if(nWindow == 98)
        return 1.0407444112814305899516580572436427374723116312638;
      
      if(nWindow == 99)
        return 1.0404096399899902452476451942062410201587631058652;

      if(nWindow == 100)
        return 1.0400808583133866839905840996075171078220420079076;
    }

    //w-NIBNAF > 100
    {
      if(nWindow == 183)
        return 1.0244312672844357862292237798272061378962120044720;

      if(nWindow == 200)
        return 1.0227024500223823696378909495239952676612396369880;

      if(nWindow == 218)
        return 1.0211391019952924292065439951738700325839419759453;

      if(nWindow == 300)
        return 1.0162081488908486099200887179950675401202202159172;

      if(nWindow == 400)
        return 1.0127372388036767299734723279220215835671835241309;

      if(nWindow == 436)
        return 1.0118466093615813680780576752210457693960703317586;

      if(nWindow == 440)
        return 1.0117558615275276266139666604128046148929763919207;  

      if(nWindow == 450)
        return 1.0115354272627753917981256263329895694631883907344;

      if(nWindow == 600)
        return 1.0090458503916447572704580506673508630558701015244;

      if(nWindow == 900)
        return 1.0064058603440620819016414846825845191663892864499;

      if(nWindow == 950)
        return 1.0061164903998645515559733901859907288672398849769;
    }  

    printf("No base found\n");
    exit(1);
  }

double mse(const arma::mat& output, const arma::mat& test)
  {
    if(output.n_rows > test.n_rows)
    {
      printf("MSE: too many output values\n");
      exit(1);
    }

    int nCoords = output.n_rows;

    double res(0.0);
    for(int i = 0; i < nCoords; i++)
    {
      res += (output(i, 0) - test(i,0)) * (output(i, 0) - test(i, 0));
    }
    res /= nCoords;

    return res;
  }

double mape(const arma::mat& output, const arma::mat& test)
  {
    if(output.n_rows > test.n_rows)
    {
      printf("MSE: too many output values\n");
      exit(1);
    }

    int nCoords = output.n_rows;

    double res(0.0);
    for(int i = 0; i < nCoords; i++)
    {
      res += std::abs((output(i, 0) - test(i,0)) / test(i, 0));
    }
    res /= nCoords;

    return res;
  }  

void convert_to_balanced(std::array<mpz_t, params::poly_t::degree>& bal_repr, double fValue, size_t nIntPrec, size_t nFracPrec)
  {
    uint32_t d = params::poly_t::degree; //should be 4096

    int tmp = int(floor(fValue * pow(3.0, nFracPrec * 1.0)+0.5));
    bool sign = true; //corresponds to a positive sign, otherwise to a negative

    size_t nLengthPrec = nFracPrec + nIntPrec;

    if(tmp < 0)
    {
      sign = false;
      tmp *= -1;
    }
    //conversion to the ternary representation
    int* r = (int*)malloc(4 * nLengthPrec);
    int i;
    for (i = 0; i < nLengthPrec; i++) r[i] = 0;
    int loc = 0;
    while (tmp > 0) 
    {
      r[loc++] = tmp % 3;
      tmp = tmp/3;

      if (loc == nLengthPrec and tmp != 0) 
      {
        printf("Overflow in toBase, value: %f\n", fValue);
        exit(1);
      }
    }

    //final conversion to the balanced ternary representation
    for (i = 0; i < nLengthPrec; i++) 
    {
      if(r[i] == 2)
      {
        r[i] = -1;
        if((i + 1) < nLengthPrec)
        {
          r[i + 1] += 1;
          int j = i + 1;
          while(r[j] == 3)
          {
            r[j] = 0;
            j++;
            if(j == nLengthPrec)
            {
              printf("Overflow in toBase, value: %f\n", fValue);
              exit(1);            
            }
            r[j] += 1;
          }
        }
        else
        {
          printf("Overflow in toBase, value: %f\n", fValue);
          exit(1);
        }
      }
      if(!sign) r[i] *= -1;
    }

    //assign coefficients to a poly
    for (size_t i = nFracPrec; i < nLengthPrec; i ++)
    {
      mpz_set_si(bal_repr[i - nFracPrec], r[i]);
      if(r[i] < 0) mpz_add(bal_repr[i - nFracPrec], bal_repr[i - nFracPrec], params::plaintextModulus<mpz_class>::value().get_mpz_t());
    }
    for (size_t i = 0; i < nFracPrec; i++)
    {
      mpz_set_si(bal_repr[d - nFracPrec + i], -r[i]);
      if (-r[i] < 0) mpz_add(bal_repr[d - nFracPrec + i], bal_repr[d - nFracPrec + i], params::plaintextModulus<mpz_class>::value().get_mpz_t());
    }

    free(r);
  }

mpf_class bal_to_float(std::array<mpz_t, params::poly_t::degree>& p, mpz_t modulusForConversion = params::plaintextModulus<mpz_class>::value().get_mpz_t())
  {
    const size_t d = params::poly_t::degree;

    mpf_t res;
    mpf_init(res);
    
    mpf_t modulus;
    mpf_init(modulus);
    mpf_set_z(modulus, modulusForConversion);

    mpf_t half_modulus;
    mpf_init(half_modulus);
    mpf_div_ui(half_modulus, modulus, 2);

    mpf_t base;
    mpf_init_set_d(base, 3.0);

    //integer part
    for (int i = 0; i < d/2; i++)
    {
      mpf_t coef;
      mpf_init(coef);
      mpf_set_z(coef,p[i]);

      mpf_t power;
      mpf_init_set(power, base);
      mpf_pow_ui(power, power, i);

      if(mpf_sgn(coef) != 0)
      {
        if (mpf_cmp(coef, half_modulus) > 0)
        {
          mpf_sub(coef, coef, modulus);
        }

        //std::cout << i << " " << coef;

        mpf_mul(coef, coef, power);

        //std::cout << " " << coef;

        mpf_add(res, res, coef);

        //std::cout << " " << res << std::endl;
      }
      mpf_clears(coef, power, nullptr);
    }

    //fractional part 
    for (int i = d - 1; i >= d/2; i--)
    {
      mpf_t coef;
      mpf_init(coef);
      mpf_set_z(coef,p[i]);

      if(mpf_sgn(coef) != 0)
      {
        if (mpf_cmp(coef, half_modulus) > 0)
          mpf_sub(coef, coef, modulus);

        mpf_t frac_exp;
        mpf_init(frac_exp);
        mpf_pow_ui(frac_exp, base, d - i );
        mpf_ui_div(frac_exp, 1, frac_exp);

        //std::cout << i << " " << coef;

        mpf_mul(coef, coef, frac_exp);

        //std::cout << " " << coef;

        mpf_sub(res, res, coef);

        //std::cout << " " << res << std::endl;

        mpf_clear(frac_exp);
      }
      mpf_clear(coef);
    }

    mpf_class res_f = mpf_class(res);

    mpf_clear(res);
    mpf_clear(modulus);
    mpf_clear(half_modulus);
    mpf_clear(base);

    return res_f;
  }

mpf_class bal_to_float(params::poly_p poly, mpz_t modulusForConversion = params::plaintextModulus<mpz_class>::value().get_mpz_t())
  {
    const size_t d = params::poly_t::degree;

    std::array<mpz_t, params::poly_t::degree> p;
    for (size_t j = 0; j < d; j++)
    {
      mpz_inits(p[j], nullptr);
    }    

    poly.poly2mpz(p);

    mpf_class res_f = bal_to_float(p);

    for (size_t j = 0; j < d; j++)
    {
      mpz_clears(p[j], nullptr);
    }

    //return res_f;
    return res_f;
  }  

mpf_class naf_to_float(std::array<mpz_t, params::poly_t::degree>& p, size_t cut_point, mpz_t modulusForConversion = params::plaintextModulus<mpz_class>::value().get_mpz_t())
  {
    if (nWindow < 1)
    {
      printf("Wrong window for conversion!\n");
      exit(1);
    }

    if(nWindow == 1)
    {
      return bal_to_float(p, modulusForConversion);
    }

    const size_t d = params::poly_t::degree;

    if(cut_point > d-1)
    {
      printf("Wrong cut point!\n");
      exit(1);
    }

    mpf_t res;
    mpf_init(res);
    
    mpf_t modulus;
    mpf_init(modulus);
    mpf_set_z(modulus, modulusForConversion);

    mpf_t half_modulus;
    mpf_init(half_modulus);
    mpf_div_ui(half_modulus, modulus, 2);

    mpf_t base;

    //positive base
    mpf_init_set_d(base, get_base(nWindow));
    //negative base
    //mpf_init_set_d(base, -get_base(nWindow));
    //integer part
    for (int i = 0; i < cut_point; i++)
    {
      mpf_t coef;
      mpf_init(coef);
      mpf_set_z(coef,p[i]);

      mpf_t power;
      mpf_init_set(power, base);
      mpf_pow_ui(power, power, i);

      if(mpf_sgn(coef) != 0)
      {
        if (mpf_cmp(coef, half_modulus) > 0)
        {
          mpf_sub(coef, coef, modulus);
        }

        //std::cout << i << " " << coef;

        mpf_mul(coef, coef, power);

        //std::cout << " " << coef;

        mpf_add(res, res, coef);

        //std::cout << " " << res << std::endl;
      }
      mpf_clears(coef, power, nullptr);
    }

    //fractional part 
    for (int i = d - 1; i >= cut_point; i--)
    {
      mpf_t coef;
      mpf_init(coef);
      mpf_set_z(coef,p[i]);

      if(mpf_sgn(coef) != 0)
      {
        if (mpf_cmp(coef, half_modulus) > 0)
          mpf_sub(coef, coef, modulus);

        mpf_t frac_exp;
        mpf_init(frac_exp);
        mpf_pow_ui(frac_exp, base, d - i );
        mpf_ui_div(frac_exp, 1, frac_exp);

        //std::cout << i << " " << coef;

        mpf_mul(coef, coef, frac_exp);

        //std::cout << " " << coef;

        mpf_sub(res, res, coef);

        //std::cout << " " << res << std::endl;

        mpf_clear(frac_exp);
      }
      mpf_clear(coef);
    }

    mpf_class res_f = mpf_class(res);

    mpf_clear(res);
    mpf_clear(modulus);
    mpf_clear(half_modulus);
    mpf_clear(base);

    return res_f;
  }

mpf_class naf_to_float(params::poly_p poly, size_t cut_point, mpz_t modulusForConversion = params::plaintextModulus<mpz_class>::value().get_mpz_t())
  {
    const size_t d = params::poly_t::degree;

    std::array<mpz_t, params::poly_t::degree> p;
    for (size_t j = 0; j < d; j++)
    {
      mpz_inits(p[j], nullptr);
    }    

    poly.poly2mpz(p);

    mpf_class res = naf_to_float(p, cut_point, modulusForConversion);

    for (size_t j = 0; j < d; j++)
    {
      mpz_clears(p[j], nullptr);
    }

    return res;
  }   

void convert_to_naf_wouter(std::array<mpz_t, params::poly_t::degree>& bal_repr, double fValue, size_t nIntPrec, size_t nFracPrec)
  {
    if (nWindow < 1)
    {
      printf("Wrong window for conversion!\n");
      exit(1);
    }

    if(nWindow == 1)
    {
      convert_to_balanced(bal_repr, fValue, nIntPrec, nFracPrec);
      return;
    }

    double base = get_base(nWindow);

    uint32_t d = params::poly_t::degree; //should be 4096
    double tmp = fValue * pow(base, nFracPrec * 1.0);
    bool sign = true; //corresponds to a positive sign, otherwise to a negative

    size_t nLengthPrec = nFracPrec + nIntPrec;

    if(tmp < 0)
    {
      sign = false;
      tmp *= -1;
    }

    int* r = (int*)malloc(4 * nLengthPrec);
    for (int i = 0; i < nLengthPrec; i++) r[i]=0;

    //conversion
    while(fabs(tmp) > 0.5)
    {
      //printf("tmp: %f\n", tmp);
      int digit = 1;
      if (tmp < 0)
      {
        tmp=fabs(tmp);
        digit = -1;
      }
      int r1 = int(floor(fmax(log(tmp-0.5)/log(base),0)));
      int r2 = int(ceil(fmax(log(tmp-0.5)/log(base),0)));

      double sumr1 = 0.5;
      double sumr2 = 0.5;

      if(floor(r1/nWindow) > 0)
      {
        for(int k = 1; k <= floor(r1/nWindow); k++)
          sumr1 += pow(base, (r1 - k * nWindow) * 1.0);
      }
      if(floor(r2/nWindow) > 0)
      {
        for(int k = 1; k <= floor(r2/nWindow); k++)
          sumr2 += pow(base, (r2 - k * nWindow) * 1.0);
      }

      if(fabs(tmp - pow(base, r1 * 1.0)) <= sumr1)
      {
        tmp -= pow(base, r1 * 1.0);
        if(r1 >= nLengthPrec)
        {
          printf("Overflow in toBase, value: %f\n", fValue);
          exit(1); 
        }
        r[r1] = digit;
      }
      else if(fabs(tmp - pow(base, r2 * 1.0)) <= sumr2)
      {
        tmp -= pow(base, r2 * 1.0);
        if(r2 >= nLengthPrec)
        {
          printf("Overflow in toBase, value: %f\n", fValue);
          exit(1); 
        }
        r[r2] = digit;
      }
      tmp *= digit;
    }


    for (int i = 0; i < nLengthPrec; i++) 
    {
      if(!sign) r[i] *= -1;
    }

    //assign coefficients to a poly
    for (size_t i = nFracPrec; i < nLengthPrec; i ++)
    {
      mpz_set_si(bal_repr[i - nFracPrec], r[i]);
      if(r[i] < 0) mpz_add(bal_repr[i - nFracPrec], bal_repr[i - nFracPrec], params::plaintextModulus<mpz_class>::value().get_mpz_t());
    }
    for (size_t i = 0; i < nFracPrec; i++)
    {
      mpz_set_si(bal_repr[d - nFracPrec + i], -r[i]);
      if (-r[i] < 0) mpz_add(bal_repr[d - nFracPrec + i], bal_repr[d - nFracPrec + i], params::plaintextModulus<mpz_class>::value().get_mpz_t());
    }

    free(r);
  }

void convert_to_naf_greedy(std::array<mpz_t, params::poly_t::degree>& bal_repr, double fValue, size_t nIntPrec, size_t nFracPrec)
  {
    if (nWindow < 1)
    {
      printf("Wrong window for conversion!\n");
      exit(1);
    }

    if(nWindow == 1)
    {
      convert_to_balanced(bal_repr, fValue, nIntPrec, nFracPrec);
      return;
    }

    double base = get_base(nWindow);

    uint32_t d = params::poly_t::degree; //should be 4096
    double tmp = fValue * pow(base, nFracPrec * 1.0);
    bool sign = true; //corresponds to a positive sign, otherwise to a negative

    size_t nLengthPrec = nFracPrec + nIntPrec;

    if(tmp < 0)
    {
      sign = false;
      tmp *= -1;
    }

    int* r = (int*)malloc(4 * nLengthPrec);
    for (int i = 0; i < nLengthPrec; i++) r[i]=0;

    //conversion
    while(fabs(tmp) > 1.0)
    {
      //printf("tmp: %f\n", tmp);
      int digit = 1;
      if (tmp < 0)
      {
        tmp=fabs(tmp);
        digit = -1;
      }
      int r1 = int(floor(fmax(log(tmp)/log(base),0)));
      int r2 = int(ceil(fmax(log(tmp)/log(base),0)));

      int cl_pow;

      if(fabs(tmp - pow(base, r1 * 1.0)) <= fabs(tmp - pow(base, r2 * 1.0))) 
        cl_pow = r1;
      else
        cl_pow = r2;

      if(cl_pow >= nLengthPrec)
        {
          printf("Overflow in toBase, value: %f\n", fValue);
          exit(1); 
        } 

      tmp -= pow(base, cl_pow * 1.0);

      //positive base
      r[cl_pow] = digit;

      tmp *= digit;     
    }


    for (int i = 0; i < nLengthPrec; i++) 
    {
      if(!sign) r[i] *= -1;
    }

    //assign coefficients to a poly
    for (size_t i = nFracPrec; i < nLengthPrec; i++)
    {
      /*
      //negative base ->
      if ((i - nFracPrec) % 2 == 1)
        r[i] *= -1;
      //<- negative base
      */

      mpz_set_si(bal_repr[i - nFracPrec], r[i]);
      if(r[i] < 0) mpz_add(bal_repr[i - nFracPrec], bal_repr[i - nFracPrec], params::plaintextModulus<mpz_class>::value().get_mpz_t());
    }
    for (size_t i = 0; i < nFracPrec; i++)
    {
      /*
      //negative base ->
      if ((i - nFracPrec) % 2 == 1)
        r[i] *= -1;
      //<- negative base
      */

      mpz_set_si(bal_repr[d - nFracPrec + i], -r[i]);
      if (-r[i] < 0) mpz_add(bal_repr[d - nFracPrec + i], bal_repr[d - nFracPrec + i], params::plaintextModulus<mpz_class>::value().get_mpz_t());
    }

    free(r);
  }

size_t int_bits(double fValue)
  {
    double tmp = fabs(fValue);
    double base = get_base(nWindow);

    int r1 = int(floor(fmax(log(tmp)/log(base),0)));
    int r2 = int(ceil(fmax(log(tmp)/log(base),0)));

    if(fabs(tmp - pow(base, r1 * 1.0)) <= fabs(tmp - pow(base, r2 * 1.0))) 
        return r1 + 1;
    else
        return r2 + 1;
  }
//generate a random balanced ternary expansion with prescribed precisions
params::poly_p random_poly(size_t nIntPrec, size_t nFracPrec)
  {
    params::poly_p poly;
    const size_t d = params::poly_t::degree;

    //initiate array
    std::array<mpz_t, params::poly_t::degree> poly_mpz;
    for (size_t j = 0; j < d; j++)
    {
      mpz_inits(poly_mpz[j], nullptr);
    }

    //integer part
    for(size_t j = 0; j < nIntPrec; j++)
    {
      int tmp = rand() % 3 - 1; 
      mpz_set_si(poly_mpz[j], tmp);
      if(tmp < 0) mpz_add(poly_mpz[j], poly_mpz[j], params::plaintextModulus<mpz_class>::value().get_mpz_t());
    }
    
    //fractional part
    for(size_t j = d - 1; j > d - 1 - nFracPrec; j--)
    {
      int tmp = rand() % 3 - 1; 
      mpz_set_si(poly_mpz[j], tmp);
      if(tmp < 0) mpz_add(poly_mpz[j], poly_mpz[j], params::plaintextModulus<mpz_class>::value().get_mpz_t());
    }

    //convert array to poly
    poly.mpz2poly(poly_mpz);

    //clean array
    for (size_t j = 0; j < d; j++)
    {
      mpz_clears(poly_mpz[j], nullptr);
    }

    return poly;
  }

//infinity norm of a polynomial
mpz_class max_coef(params::poly_p p)
  {
    const size_t d = params::poly_t::degree;

    //initiate array
    std::array<mpz_t, params::poly_t::degree> poly_mpz;
    for (size_t j = 0; j < d; j++)
    {
      mpz_inits(poly_mpz[j], nullptr);
    }

    p.poly2mpz(poly_mpz);

    mpz_t max;
    mpz_init(max);

    mpz_t modulus;
    mpz_init(modulus);
    mpz_set(modulus, params::plaintextModulus<mpz_class>::value().get_mpz_t());

    mpz_t half_modulus;
    mpz_init(half_modulus);
    mpz_div_ui(half_modulus, modulus, 2);

    for(size_t j = 0; j < d; j++)
    {
      if (mpz_cmp(poly_mpz[j], half_modulus) > 0)
          mpz_sub(poly_mpz[j], poly_mpz[j], modulus);
      if(mpz_cmp(poly_mpz[j], max) > 0)
        mpz_set(max, poly_mpz[j]);
    }

    //clean array
    for (size_t j = 0; j < d; j++)
    {
      mpz_clears(poly_mpz[j], nullptr);
    }

    return mpz_class(max); 
  }

//noise of a ciphertext
size_t poly_noise(sk_t const &sk, pk_t const &pk, FV::ciphertext_t const &ct) 
  {
    using P = params::poly_p;
    const size_t d = P::degree;

    P poly_m;
    std::array<mpz_t, d> bal_repr;
    for (size_t j = 0; j < d; j++)
    {
      mpz_inits(bal_repr[j], nullptr);
    }
    FV::decrypt_poly(bal_repr, sk, pk, ct);
    poly_m.mpz2poly(bal_repr);

    poly_m.ntt_pow_phi();

    P numerator{ct.c0 + ct.c1 * sk.value -
                nfl::shoup(poly_m * pk.delta, pk.delta_shoup)};
    numerator.invntt_pow_invphi();
    std::array<mpz_t, P::degree> poly_mpz = numerator.poly2mpz();

    size_t logMax = 0;

    for (size_t i = 0; i < P::degree; i++) {
      util::center(poly_mpz[i], poly_mpz[i], P::moduli_product(),
                   pk.evk->qDivBy2);
      logMax = std::max(logMax, mpz_sizeinbase(poly_mpz[i], 2));
    }

    // Clean
    for (size_t i = 0; i < P::degree; i++) {
      mpz_clear(poly_mpz[i]);
    }

    for (size_t j = 0; j < d; j++)
    {
      mpz_clears(bal_repr[j], nullptr);
    }

    return logMax;
  }

void print_poly(params::poly_p const &poly, bool bPlaintext = false)
  {
    params::poly_p tmp_poly = poly;
    mpz_t modulus;
    mpz_init(modulus);
    if(bPlaintext)
      mpz_set(modulus, params::plaintextModulus<mpz_class>::value().get_mpz_t());
    else
      mpz_set(modulus, params::poly_p::moduli_product());

    mpz_t half_modulus;
    mpz_init(half_modulus);
    mpz_div_ui(half_modulus, modulus, 2);

    const size_t d = params::poly_p::degree;
    std::array<mpz_t, d> res_repr;
    for (size_t k = 0; k < d; k++)
    {
      mpz_inits(res_repr[k], nullptr);
    }

    tmp_poly.poly2mpz(res_repr);

    bool bFirst = true;

    for(int k = 0; k < d; k++)
    {
      if(mpz_sgn(res_repr[k]) != 0)
      {
        if(!bFirst)
          std::cout << " + ";
        else
          bFirst = false;
        mpz_t tmp;
        mpz_init_set(tmp, res_repr[k]);
        mpz_mod(tmp,tmp,modulus);
        if(mpz_cmp(tmp, half_modulus) > 0)
          mpz_sub(tmp, tmp, modulus);
        std::cout << mpz_class(tmp).get_str() << " * x^" << k;
        mpz_clear(tmp);
      }
    }
    std::cout << std::endl;

    for (size_t k = 0; k < d; k++)
    {
      mpz_clears(res_repr[k], nullptr);
    }  
  }

void write_poly(params::poly_p &poly, std::ofstream& file)
  {
    const size_t d = params::poly_p::degree;
    std::array<mpz_t, d> res_repr;
    for (size_t k = 0; k < d; k++)
    {
      mpz_inits(res_repr[k], nullptr);
    }

    poly.poly2mpz(res_repr);

    for(int k = 0; k < d; k++)
    {
      file << mpz_class(res_repr[k]).get_str();
      file << std::endl;
    }
    file << std::endl;

    for (size_t k = 0; k < d; k++)
    {
      mpz_clears(res_repr[k], nullptr);
    }
  }

void print_encoding(std::array<mpz_t, params::poly_p::degree>const &poly, int nInputIntPrec, int nInputFracPrec, mpz_class curModulus)
  {
    const size_t d = params::poly_p::degree;
    mpz_t modulus;
    mpz_init(modulus);
    mpz_set(modulus, curModulus.get_mpz_t());

    mpz_t half_modulus;
    mpz_init(half_modulus);
    mpz_div_ui(half_modulus, modulus, 2); 
    std::cout << "[";
    //print integral part
    for(int k = nInputIntPrec - 1; k >= 0; k--)
    {
      mpz_t tmp;
      mpz_init_set(tmp, poly[k]);
      mpz_mod(tmp,tmp,modulus);
      if(mpz_cmp(tmp, half_modulus) > 0)
        mpz_sub(tmp, tmp, modulus);
      std::cout << mpz_class(tmp).get_str() << " ";
      mpz_clear(tmp);
    }
    std::cout << ".";
    //print fractional part
    for(int k = 1; k <= nInputFracPrec; k++)
    {
      mpz_t tmp;
      mpz_init_set(tmp, poly[d-k]);
      mpz_mod(tmp,tmp,modulus);
      if(mpz_cmp(tmp, half_modulus) > 0)
        mpz_sub(tmp, tmp, modulus);
      mpz_neg(tmp, tmp);
      std::cout << mpz_class(tmp).get_str() << " ";
      mpz_clear(tmp);
    }
    std::cout << "]";
    std::cout << std::endl;
    mpz_clear(modulus);
    mpz_clear(half_modulus);
  }

void print_poly_array(std::array<mpz_t, params::poly_p::degree>const &poly)
  {
    for(int k = 0; k < params::poly_p::degree; k++)
    {
      if(mpz_sgn(poly[k]) != 0)
        std::cout << mpz_class(poly[k]).get_str() << " * x^" << k << " + ";
    }
    std::cout << std::endl;
  }

void print_poly_degrees(params::poly_p &poly)
  {
    int intDeg = cut_point;
    int fracDeg = cut_point;

    const size_t d = params::poly_p::degree;
    std::array<mpz_t, d> res_repr;
    for (size_t k = 0; k < d; k++)
    {
      mpz_inits(res_repr[k], nullptr);
    }

    poly.poly2mpz(res_repr);

    while(intDeg > -1 && mpz_sgn(res_repr[intDeg]) == 0)
    {
      intDeg--;
    }
    while(fracDeg < d && mpz_sgn(res_repr[fracDeg]) == 0)
    {
      fracDeg++;
    }
    std::cout << "Int. degree: " << intDeg << std::endl;
    std::cout << "Frac. degree: " << d - fracDeg << std::endl;
  }

void fit_to_modulus(std::array<mpz_t, params::poly_p::degree>& polym, mpz_t modulus)
  {
    for (int i = 0; i < params::poly_p::degree; i++)
    {
      mpz_mod(polym[i], polym[i], modulus);
    }
  }

//the function that splits the polynomial representation of a real value according to the different moduli
void convert_to_crt(std::array<params::poly_p, nPltxtModuli>& poly_crt, double fValue, size_t nIntPrec, size_t nFracPrec)
  {
    for(size_t iPltxtMod = 0; iPltxtMod < nPltxtModuli; iPltxtMod++)
    {
      params::plaintextModulus<mpz_class>::value_mpz = mpz_class(plaintextModuli[iPltxtMod]);
      std::array<mpz_t, params::poly_p::degree> bal_repr;
      for (size_t i = 0; i < params::poly_p::degree; i++)
      {
        mpz_inits(bal_repr[i], nullptr);
      }

      convert_to_naf_greedy(bal_repr, fValue, nIntPrec, nFracPrec);
      poly_crt[n].mpz2poly(bal_repr);

      for (size_t i = 0; i < params::poly_p::degree; i++)
      {
        mpz_clears(bal_repr[i], nullptr);
      }
      params::plaintextModulus<mpz_class>::reset();
    }
  }

void convert_to_crt_one_modulus(params::poly_p& poly_crt, double fValue, size_t nIntPrec, size_t nFracPrec)
  {
      std::array<mpz_t, params::poly_p::degree> bal_repr;
      for (size_t i = 0; i < params::poly_p::degree; i++)
      {
        mpz_inits(bal_repr[i], nullptr);
      }

      convert_to_naf_greedy(bal_repr, fValue, nIntPrec, nFracPrec);
      poly_crt.mpz2poly(bal_repr);

      for (size_t i = 0; i < params::poly_p::degree; i++)
      {
        mpz_clears(bal_repr[i], nullptr);
      } 
  }

//conversion from crt representation to float
mpf_class convert_from_crt(std::array<params::poly_p, nPltxtModuli>& poly_crt, size_t cut_point)
  {
    std::array<mpz_t, params::poly_p::degree> res_poly;
    mpf_class fRes;
    
    for (size_t i = 0; i < params::poly_p::degree; i++)
    {
      mpz_inits(res_poly[i], nullptr);
    }

    mpz_t quotient, current_modulus, lifting_integer;
    mpz_inits(quotient, current_modulus, lifting_integer, nullptr);
    
    //loop over all moduli
    for (size_t j = 0; j < nPltxtModuli; j++)
    {
      // Current modulus
      mpz_set_str(current_modulus, plaintextModuli[j], 10);
    
      // compute the product of primes except the current one
      mpz_divexact(quotient, params::plaintextModulus<mpz_class>::product().get_mpz_t(), current_modulus);

      // Compute the inverse of the product
      mpz_init2(lifting_integer, params::plaintextModulus<mpz_class>::bits_in_moduli_product);
      mpz_invert(lifting_integer, quotient, current_modulus);

      // Multiply by the quotient
      mpz_mul(lifting_integer, lifting_integer, quotient);

      std::array<mpz_t, params::poly_p::degree> cur_poly;
      for (size_t i = 0; i < params::poly_p::degree; i++)
      {
        mpz_inits(cur_poly[i], nullptr);
      }
      poly_crt[j].poly2mpz(cur_poly);

      for (size_t i = 0; i < params::poly_p::degree; i++)
      {
        if (mpz_sgn(cur_poly[i])!= 0)
          mpz_addmul(res_poly[i], lifting_integer, cur_poly[i]);
      }

      for (size_t i = 0; i < params::poly_p::degree; i++)
      {
        mpz_clears(cur_poly[i], nullptr);
      }    
    }

    mpz_clears(quotient, current_modulus, lifting_integer, nullptr);

    params::plaintextModulus<mpz_class>::reset();

    fit_to_modulus(res_poly, params::plaintextModulus<mpz_class>::value().get_mpz_t());
    fRes = naf_to_float(res_poly, cut_point);

    for (size_t i = 0; i < params::poly_p::degree; i++)
    {
      mpz_clears(res_poly[i], nullptr);
    }

    return fRes;  
  }

params::poly_p convert_to_simd(std::array<params::poly_p, nPltxtModuli> polys)
  {
    std::array<mpz_t, params::poly_p::degree> res_poly;
    
    for (size_t i = 0; i < params::poly_p::degree; i++)
    {
      mpz_inits(res_poly[i], nullptr);
    }

    mpz_t quotient, current_modulus, lifting_integer;
    mpz_inits(quotient, current_modulus, lifting_integer, nullptr);
    
    //loop over all moduli
    for (size_t j = 0; j < nPltxtModuli; j++)
    {
      // Current modulus
      mpz_set_str(current_modulus, plaintextModuli[j], 10);
    
      // compute the product of primes except the current one
      mpz_divexact(quotient, params::plaintextModulus<mpz_class>::product().get_mpz_t(), current_modulus);

      // Compute the inverse of the product
      mpz_init2(lifting_integer, params::plaintextModulus<mpz_class>::bits_in_moduli_product);
      mpz_invert(lifting_integer, quotient, current_modulus);

      // Multiply by the quotient
      mpz_mul(lifting_integer, lifting_integer, quotient);

      std::array<mpz_t, params::poly_p::degree> cur_poly;
      for (size_t i = 0; i < params::poly_p::degree; i++)
      {
        mpz_inits(cur_poly[i], nullptr);
      }
      polys[j].poly2mpz(cur_poly);

      for (size_t i = 0; i < params::poly_p::degree; i++)
      {
        if (mpz_sgn(cur_poly[i])!= 0)
          mpz_addmul(res_poly[i], lifting_integer, cur_poly[i]);
      }

      for (size_t i = 0; i < params::poly_p::degree; i++)
      {
        mpz_clears(cur_poly[i], nullptr);
      }    
    }

    mpz_clears(quotient, current_modulus, lifting_integer, nullptr);

    params::plaintextModulus<mpz_class>::reset();

    fit_to_modulus(res_poly, params::plaintextModulus<mpz_class>::value().get_mpz_t());

    params::poly_p res_poly_p;
    res_poly_p.mpz2poly(res_poly);

    return res_poly_p;
  }

void convert_from_simd(std::array<params::poly_p, nPltxtModuli>& polys, std::array<mpz_t, params::poly_p::degree> poly2conv)
  {
    for(size_t modInd = 0; modInd < nPltxtModuli; modInd++)
    {
      mpz_t curmod;
      mpz_init(curmod);
      mpz_set_str(curmod, plaintextModuli[modInd], 10);
      
      std::array<mpz_t, params::poly_p::degree> polymod;
      for (size_t i = 0; i < params::poly_p::degree; i++)
      {
        mpz_inits(polymod[i], nullptr);
        mpz_tdiv_r(polymod[i], poly2conv[i], curmod);
      }

      polys[modInd].mpz2poly(polymod);

      for (size_t i = 0; i < params::poly_p::degree; i++)
      {
        mpz_clears(polymod[i], nullptr);
      }
      mpz_clear(curmod);
    }
  }

FV::ciphertext_t poly_to_ciphertext(pk_t &pk, params::poly_p const &poly)
  {
    FV::ciphertext_t ct;
    ct.pk = &pk;
    ct.c0 = poly;
    ct.c0.ntt_pow_phi();
    ct.c0 = nfl::shoup(ct.c0 * ct.pk->delta, ct.pk->delta_shoup);
    ct.isnull = false;

    return ct;
  }

void convert_cphrtxt_to_c(FV::ciphertext_t const &c, long long int c0[][4096], long long int c1[][4096])
  {
    params::poly_p c0fv{c.c0};
    params::poly_p c1fv{c.c1};

    c0fv.invntt_pow_invphi();
    c1fv.invntt_pow_invphi();

    const size_t d = params::poly_t::degree;

    //initiate array
    std::array<mpz_t, params::poly_t::degree> c0fv_mpz;
    std::array<mpz_t, params::poly_t::degree> c1fv_mpz;
    for (size_t i = 0; i < d; i++)
    {
      mpz_inits(c0fv_mpz[i], nullptr);
      mpz_inits(c1fv_mpz[i], nullptr);
    }

    c0fv.poly2mpz(c0fv_mpz);
    c1fv.poly2mpz(c1fv_mpz);

    for (size_t i = 0; i < (sizeof(q_factors)/sizeof(*q_factors)); i++)
    {
      for (size_t j = 0; j < d; j++)
      {
        mpz_t tmp;
        mpz_init(tmp);
        
        mpz_set(tmp, c0fv_mpz[j]);
        c0[i][j] = mpz_mod_ui(tmp, tmp, q_factors[i]);

        mpz_set(tmp, c1fv_mpz[j]);
        c1[i][j] = mpz_mod_ui(tmp, tmp, q_factors[i]);

        mpz_clear(tmp);
      }
    }

    for (size_t i = 0; i < d; i++)
    {
      mpz_clears(c0fv_mpz[i], nullptr);
      mpz_clears(c1fv_mpz[i], nullptr);
    }
  }

void zeroize(long long int arr[6][4096])
{
  for(int i = 0; i < 6; i++)
  {
    for(int j = 0; j < 4096; j++)
    {
      arr[i][j] = 0;
    }
  }
}

class gmdh_net_layer
  {
    //number of nodes
    size_t m_nNodes;
    

    std::vector<bool> m_NodeFlags; //a flag is true when a node has to be evaluated in order to compute the final output

    //wiring with the previous layer
    arma::mat m_aConnections;
    
    //balanced ternary expansion of polynomial coefficients corresponding to the current plaintext modulus
    std::vector<std::vector<params::poly_p>> m_crtPolynoms;
    
    //polynomial coefficients as real numbers
    arma::mat m_Polynoms;

    //polynomial coefficients approximated by w-NIBNAF
    arma::mat m_PolynomsApprox;

    //current plaintext modulus
    mpz_class m_mpzModulus;

    //output of the layer
    arma::mat m_Output;

    //error (MSE) of node output values
    arma::vec m_OutputError;

    //index of the minimal error node
    size_t m_iMinErrorNode;

    //regularization parameters of nodes chosen by the algorithm after training
    arma::vec m_NodeAlphas;

    //precision of balanced ternary expansion
    size_t m_nIntPrec;
    size_t m_nFracPrec;
    
    //indicates whether network coefficients are encoded
    bool m_bIsEncoded;

    //indicates whether the network was trained and output data together with error values was saved
    bool m_bHasOutput;

  public:
    gmdh_net_layer(): m_nNodes(0), m_OutputError(0.0), m_iMinErrorNode(0), m_bIsEncoded(false), m_bHasOutput(false) {}

    gmdh_net_layer(int nNodes, arma::mat aConnections, arma::mat aPolynoms, arma::mat output, size_t iMinErrorNode, arma::vec outputError, arma::vec nodeAlphas, mpz_class mpzModulus): m_nNodes(nNodes), m_mpzModulus(mpzModulus), m_bIsEncoded(false), m_bHasOutput(true)
      {
        if (aConnections.n_rows != nNodes)
        {
          printf("Invalid number of connections given\n");
          exit(1);
        }
        else
          m_aConnections = aConnections;

        if (aPolynoms.n_rows != nNodes)
        {
          printf("Invalid number of polynomials given\n");
          exit(1);
        }
        else
        {
          m_Polynoms = aPolynoms;
        }

        if(output.n_cols != nNodes)
        {
          printf("Invalid number of output values\n");
          exit(1);
        }
        else
        {
          m_Output = output;
          m_OutputError = outputError;
          m_iMinErrorNode = iMinErrorNode;
          m_NodeAlphas = nodeAlphas;
        }

        for(int iNode = 0; iNode < m_nNodes; iNode++)
        {
          m_NodeFlags.push_back(true);
        }
      }

    gmdh_net_layer(int nNodes, arma::mat aConnections, arma::mat aPolynoms, arma::vec nodeAlphas, mpz_class mpzModulus): m_nNodes(nNodes), m_mpzModulus(mpzModulus), m_bIsEncoded(false), m_bHasOutput(false)
      {
        if (aConnections.n_rows != nNodes)
        {
          printf("Invalid number of connections given\n");
          exit(1);
        }
        else
          m_aConnections = aConnections;

        if (aPolynoms.n_rows != nNodes)
        {
          printf("Invalid number of polynomials given\n");
          exit(1);
        }
        else
        {
          m_Polynoms = aPolynoms;
        }

        if(nodeAlphas.n_elem != nNodes)
        {
          printf("Invalid number of alpha values %llu\n", nodeAlphas.n_cols);
          exit(1);
        }
        else
        {
          m_NodeAlphas = nodeAlphas;
        }

        for(int iNode = 0; iNode < m_nNodes; iNode++)
        {
          m_NodeFlags.push_back(true);
        }
      }

    void encode_coefs(size_t nIntPrec, size_t nFracPrec)
      {
        m_nIntPrec = nIntPrec;
        m_nFracPrec = nFracPrec;

        m_PolynomsApprox = arma::mat(arma::size(m_Polynoms));

        for (int iNode = 0; iNode < m_nNodes; iNode++)
          {
            if(m_NodeFlags[iNode])
            {
              std::vector<params::poly_p> tmpRowCRT;
              for (int j = 0; j < m_Polynoms.n_cols; j++)
              {
                params::poly_p tmp;
                convert_to_crt_one_modulus(tmp, m_Polynoms(iNode,j), nIntPrec, nFracPrec);
                m_PolynomsApprox(iNode,j) = naf_to_float(tmp, cut_point_init, params::plaintextModulus<mpz_class>::product_mpz.get_mpz_t()).get_d();

                tmpRowCRT.push_back(tmp);
              }
              m_crtPolynoms.push_back(tmpRowCRT);
            }
            else
            {
              m_crtPolynoms.push_back(std::vector<params::poly_p>());
            }
          }

        m_bIsEncoded = true;
      }

    void get_connections(int& nInputNode1, int& nInputNode2, int nCurNode) const
      {
        nInputNode1 = m_aConnections(nCurNode, 0);
        nInputNode2 = m_aConnections(nCurNode, 1);
      }

    arma::mat get_output() const
      {
        if(!m_bHasOutput)
        {
          printf("Layer output is not defined\n");
          exit(1);
        }
        return m_Output;
      }

    void get_poly(std::vector<params::poly_p>& aPoly, int nCurNode) const
      {
        if(!m_bIsEncoded)
        {
          printf("gmdh_net_layer.get_poly: coefficients are not encoded\n");
          exit(1); 
        }

        aPoly.clear();
        for (size_t i = 0; i < m_crtPolynoms[nCurNode].size(); i++)
        {
          aPoly.push_back(m_crtPolynoms[nCurNode][i]);
        }
      }

    arma::mat get_poly_plain(int nCurNode) const
      {
        return m_Polynoms.row(nCurNode);
      }

    size_t get_num_nodes() const
      {
        return m_nNodes;
      }

    double get_min_error() const
      {
        if(!m_bHasOutput)
        {
          printf("Layer output is not defined\n");
          exit(1);
        }
        return m_OutputError[m_iMinErrorNode];
      }

    size_t get_min_error_node() const
      {
        if(!m_bHasOutput)
        {
          printf("Layer output is not defined\n");
          exit(1);
        }
        return m_iMinErrorNode;
      }

    void set_modulus(mpz_class mpzModulus)
      {
        m_mpzModulus = mpzModulus;

        m_crtPolynoms.clear();
        for (int iNode = 0; iNode < m_nNodes; iNode++)
          {
            if(m_NodeFlags[iNode])
            {
              std::vector<params::poly_p> tmpRowCRT;
              for (int j = 0; j < m_Polynoms.n_cols; j++)
              {
                params::poly_p tmp;
                convert_to_crt_one_modulus(tmp, m_Polynoms(iNode,j), m_nIntPrec, m_nFracPrec);

                tmpRowCRT.push_back(tmp);
              }
              m_crtPolynoms.push_back(tmpRowCRT);
            }
            else
            {
              m_crtPolynoms.push_back(std::vector<params::poly_p>());
            }
          }
      }

    //turn off unnecessary nodes for the final output
    void update_nodes(std::vector<size_t> nodesToRemain)
      {
        for(int iNode = 0; iNode < m_nNodes; iNode++)
        {
          m_NodeFlags[iNode] = false;
        }


        for(size_t iNode = 0; iNode < nodesToRemain.size(); iNode++)
        {
          m_NodeFlags[nodesToRemain[iNode]] = true;
        }
      }

    std::vector<size_t> get_input_nodes() const
      {
        if(!m_bHasOutput)
          printf("Layer input is not defined\n");

        std::vector<size_t> resNodes;

        for(int iNode = 0; iNode < m_nNodes; iNode++)
          {
            if(m_NodeFlags[iNode])
            {
              size_t inputNode0 = int(m_aConnections(iNode, 0));
              size_t inputNode1 = int(m_aConnections(iNode, 1));

              std::sort(resNodes.begin(), resNodes.end());

              if(!std::binary_search(resNodes.begin(), resNodes.end(), inputNode0))
                resNodes.push_back(inputNode0);

              if(!std::binary_search(resNodes.begin(), resNodes.end(), inputNode1))
                resNodes.push_back(inputNode1);
            }
          }
        return resNodes;
      }

    void print() const
      {
        std::cout << "Modulus: " << m_mpzModulus << std::endl;
        for (int iNode = 0; iNode < m_nNodes; iNode++)
        {
          if(m_NodeFlags[iNode])
          {
            std::cout << "Node " << iNode << std::endl;
            std::cout << "Input 0: " << m_aConnections(iNode, 0) << std::endl;
            std::cout << "Input 1: " << m_aConnections(iNode, 1) << std::endl;
            std::cout << "Polynomial coefficients: " <<  m_Polynoms.row(iNode);
            if(m_bHasOutput)
              std::cout << "Error: " << m_OutputError(iNode) << std::endl;
            std::cout << "Alpha: " << m_NodeAlphas(iNode) << std::endl;
            std::cout << std::endl;  
          }  
        }
        std::cout << std::endl;
      }

    void print_encodings() const
      {
        for (size_t iNode = 0; iNode < m_nNodes; iNode++)
        {
          if(m_NodeFlags[iNode])
          {
            printf("Node %zu\n", iNode);
            std::cout << "Input 0: " << m_aConnections(iNode, 0) << std::endl;
            std::cout << "Input 1: " << m_aConnections(iNode, 1) << std::endl;
            for(size_t j = 0; j < m_Polynoms.n_cols; j++)
            {
              print_poly(m_crtPolynoms[iNode][j], true);
            }
          }
        }
      }

    double get_max_abs_coef() const
      {
        double res = 0.0;

        for (int iNode = 0; iNode < m_nNodes; iNode++)
        {
          if (m_NodeFlags[iNode])
          {
            for(int iCol = 0; iCol < m_Polynoms.n_cols; iCol++)
            {
              if (fabs(m_Polynoms(iNode, iCol)) > res)
                res = fabs(m_Polynoms(iNode, iCol));  
            }
            
          }
        }
        return res;
      }

    //evaluate nodes in the homomorphic mode
    std::vector<FV::ciphertext_t> evaluate_enc(std::vector<FV::ciphertext_t>& cSample, pk_t *pk, sk_t *sk)
      {
        if(!m_bIsEncoded)
        {
          printf("gmdh_net_layer.evaluate_enc: coefficients are not encoded\n");
          exit(1); 
        }
        std::vector<FV::ciphertext_t> output;

        for(int iNode = 0; iNode < m_nNodes; iNode++)
        {
          FV::ciphertext_t nodeOutput;
          if(m_NodeFlags[iNode])
          {
            //printf("Evaluate node %d.\n", iNode + 1);
            //std::cout << "Polynomial coefs: " << m_Polynoms.row(iNode);
            
            size_t nCoef = m_crtPolynoms[iNode].size(); 
            if (nCoef < m_Polynoms.n_cols)
            {
             printf("evaluate_enc: Number of coefs is less than %llu! %zu instead. \n", m_Polynoms.n_cols, nCoef);
             exit(1);
            }

            std::array<FV::ciphertext_t, 6> c_aPoly;
            for(size_t i = 0; i < m_Polynoms.n_cols; i++)
            {
              c_aPoly[i] = poly_to_ciphertext(*pk, m_crtPolynoms[iNode][i]);
            }
            
            //std::cout << "Current modulus: " << params::plaintextModulus<mpz_class>::value().get_mpz_t() << std::endl;

            //std::cout << "Initial noise: " << poly_noise(*sk, *pk, cSample[m_aConnections(iNode,0)]) << " and " << poly_noise(*sk, *pk, cSample[m_aConnections(iNode,1)]) << "/" << pk->noise_max << std::endl;

            nodeOutput = cSample[m_aConnections(iNode,0)] * c_aPoly[1];            
            nodeOutput += cSample[m_aConnections(iNode,1)] * c_aPoly[2];
            nodeOutput += cSample[m_aConnections(iNode,0)] * cSample[m_aConnections(iNode,1)] * c_aPoly[3];
            nodeOutput += cSample[m_aConnections(iNode,0)] * cSample[m_aConnections(iNode,0)] * c_aPoly[4];
            nodeOutput += cSample[m_aConnections(iNode,1)] * cSample[m_aConnections(iNode,1)] * c_aPoly[5];
            nodeOutput += c_aPoly[0];

            /*
            //if(poly_noise(*sk, *pk, nodeOutput) > pk->noise_max)
            {
              std::cout << "Current modulus: " << params::plaintextModulus<mpz_class>::value().get_mpz_t() << std::endl;
              std::cout << "Output noise: " << poly_noise(*sk, *pk, nodeOutput) << "/" << pk->noise_max << std::endl;
            }
            */
          }
          output.push_back(nodeOutput);
        }
        return output;
      }

      //evaluate nodes in the homomorphic mode
    std::vector<FV::ciphertext_t> evaluate_suj(std::vector<FV::ciphertext_t>& cSample, pk_t *pk, sk_t *sk)
      { 

        
        if(!m_bIsEncoded)
        {
          printf("gmdh_net_layer.evaluate_enc: coefficients are not encoded\n");
          exit(1); 
        }
        std::vector<FV::ciphertext_t> output;

        for(int iNode = 0; iNode < m_nNodes; iNode++)
        {
          FV::ciphertext_t nodeOutput;
          if(m_NodeFlags[iNode])
          {
            // printf("Evaluate node %d.\n", iNode + 1);
            // std::cout << "Polynomial coefs: " << m_Polynoms.row(iNode);
            
            size_t nCoef = m_crtPolynoms[iNode].size(); 
            if (nCoef < m_Polynoms.n_cols)
            {
             printf("evaluate_enc: Number of coefs is less than %llu! %zu instead. \n", m_Polynoms.n_cols, nCoef);
             exit(1);
            }

            std::array<FV::ciphertext_t, 6> c_aPoly;
            for(size_t i = 0; i < m_Polynoms.n_cols; i++)
            {
              c_aPoly[i] = poly_to_ciphertext(*pk, m_crtPolynoms[iNode][i]);
            }
            
            // std::cout << "Current modulus: " << params::plaintextModulus<mpz_class>::value().get_mpz_t() << std::endl;
            // std::cout << "Initial noise: " << poly_noise(*sk, *pk, cSample[m_aConnections(iNode,0)]) << " and " << poly_noise(*sk, *pk, cSample[m_aConnections(iNode,1)]) << "/" << pk->noise_max << std::endl;

            long long int tmp10[NUM_PRIME_EXT][4096];
            long long int tmp11[NUM_PRIME_EXT][4096];
            long long int tmp20[NUM_PRIME_EXT][4096];
            long long int tmp21[NUM_PRIME_EXT][4096];
            long long int tmp30[NUM_PRIME_EXT][4096];
            long long int tmp31[NUM_PRIME_EXT][4096];

            long long int res0[NUM_PRIME_EXT][4096];
            long long int res1[NUM_PRIME_EXT][4096];

            mpz_t res_mpz0[4096];
            mpz_t res_mpz1[4096];

            std::array<mpz_t, params::poly_p::degree> p0_array;
            std::array<mpz_t, params::poly_p::degree> p1_array;

            params::poly_p p0;
            params::poly_p p1;

            for (size_t i = 0; i < params::poly_p::degree; i++)
            {
              mpz_inits(p0_array[i], nullptr);
              mpz_inits(p1_array[i], nullptr);
            }

            mpz_array_init(res_mpz0[0], 4096, 512);
            mpz_array_init(res_mpz1[0], 4096, 512);



struct timespec tstart={0,0}, tend={0,0};    
            
            
            //nodeOutput = cSample[m_aConnections(iNode,0)] * c_aPoly[1];
            convert_cphrtxt_to_c(cSample[m_aConnections(iNode,0)], tmp10, tmp11);
            convert_cphrtxt_to_c(c_aPoly[1], tmp20, tmp21);
            
          // clock_gettime(CLOCK_MONOTONIC, &tstart);
          
            HE_MUL_HW(tmp10, tmp11, tmp20, tmp21, res0, res1);
          
          // clock_gettime(CLOCK_MONOTONIC, &tend);
          // printf("HE_MUL_HW took about %.5f seconds\n",
          //   ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - 
          //   ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec));

          // clock_gettime(CLOCK_MONOTONIC, &tstart);
            // FV_mul(tmp10, tmp11, tmp20, tmp21, res0, res1);
            // HE_COMPARE(res0, res1);
          // clock_gettime(CLOCK_MONOTONIC, &tend);
          // printf("FV_mul took about %.5f seconds\n",
          //   ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - 
          //   ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec));

            // getchar();
                       
            //nodeOutput += cSample[m_aConnections(iNode,1)] * c_aPoly[2];
            convert_cphrtxt_to_c(cSample[m_aConnections(iNode,1)], tmp10, tmp11);
            convert_cphrtxt_to_c(c_aPoly[2], tmp20, tmp21);
            HE_MUL_HW(tmp10, tmp11, tmp20, tmp21, tmp30, tmp31);
            FV_add(res0, res1, tmp30, tmp31, res0, res1);
            
            
            //nodeOutput += cSample[m_aConnections(iNode,0)] * cSample[m_aConnections(iNode,1)] * c_aPoly[3];
            convert_cphrtxt_to_c(cSample[m_aConnections(iNode,0)], tmp10, tmp11);
            
            convert_cphrtxt_to_c(cSample[m_aConnections(iNode,1)], tmp20, tmp21);
            
            HE_MUL_HW(tmp10, tmp11, tmp20, tmp21, tmp30, tmp31);
            
            convert_cphrtxt_to_c(c_aPoly[3], tmp20, tmp21);
            
            HE_MUL_HW(tmp30, tmp31, tmp20, tmp21, tmp10, tmp11);
            
            FV_add(res0, res1, tmp10, tmp11, res0, res1);
            
            
            //nodeOutput += cSample[m_aConnections(iNode,0)] * cSample[m_aConnections(iNode,0)] * c_aPoly[4];
            convert_cphrtxt_to_c(cSample[m_aConnections(iNode,0)], tmp10, tmp11);
            convert_cphrtxt_to_c(cSample[m_aConnections(iNode,0)], tmp20, tmp21);
            HE_MUL_HW(tmp10, tmp11, tmp20, tmp21, tmp30, tmp31);
            convert_cphrtxt_to_c(c_aPoly[4], tmp20, tmp21);
            HE_MUL_HW(tmp30, tmp31, tmp20, tmp21, tmp10, tmp11);
            FV_add(res0, res1, tmp10, tmp11, res0, res1);
            
            
            //nodeOutput += cSample[m_aConnections(iNode,1)] * cSample[m_aConnections(iNode,1)] * c_aPoly[5];
            convert_cphrtxt_to_c(cSample[m_aConnections(iNode,1)], tmp10, tmp11);
            convert_cphrtxt_to_c(cSample[m_aConnections(iNode,1)], tmp20, tmp21);
            HE_MUL_HW(tmp10, tmp11, tmp20, tmp21, tmp30, tmp31);
            convert_cphrtxt_to_c(c_aPoly[5], tmp20, tmp21);
            HE_MUL_HW(tmp30, tmp31, tmp20, tmp21, tmp10, tmp11);
            FV_add(res0, res1, tmp10, tmp11, res0, res1);
            
            
            //nodeOutput += c_aPoly[0];
            convert_cphrtxt_to_c(c_aPoly[0], tmp10, tmp11);
            FV_add(res0, res1, tmp10, tmp11, res0, res1);

            inverse_crt_length7(res0, res_mpz0);
            inverse_crt_length7(res1, res_mpz1);

            for (size_t i = 0; i < params::poly_p::degree; i++)
            {
              mpz_set(p0_array[i], res_mpz0[i]);
              mpz_set(p1_array[i], res_mpz1[i]);
            }

            p0.mpz2poly(p0_array);
            p1.mpz2poly(p1_array);

            nodeOutput = FV::ciphertext_t(p0, p1, *pk);
            
            for (size_t i = 0; i < params::poly_p::degree; i++)
            {
              mpz_clears(p0_array[i], nullptr);
              mpz_clears(p1_array[i], nullptr);
            }

            mpz_clear(res_mpz0[0]);
            mpz_clear(res_mpz1[0]);

            /*
            //if(poly_noise(*sk, *pk, nodeOutput) > pk->noise_max)
            {
              std::cout << "Current modulus: " << params::plaintextModulus<mpz_class>::value().get_mpz_t() << std::endl;
              std::cout << "Output noise: " << poly_noise(*sk, *pk, nodeOutput) << "/" << pk->noise_max << std::endl;
            }
            */
          }
          output.push_back(nodeOutput);
        }
        return output;
      }

    //evaluate nodes in the real domain
    arma::rowvec evaluate_double(arma::rowvec vSample)
      {
        arma::rowvec output(m_nNodes);

        for(int iNode = 0; iNode < m_nNodes; iNode++)
        {
          if(m_NodeFlags[iNode])
          {
            //printf("Evaluate node %d.\n", iNode + 1);
            //std::cout << "Polynomial coefs: " << m_Polynoms.row(iNode);
             
            //printf("Input values: %f,%f\n", vSample(m_aConnections(iNode,0)), m_Polynoms(iNode,1));

            output(iNode) = vSample[m_aConnections(iNode,0)] * m_Polynoms(iNode,1);
            output(iNode) += vSample[m_aConnections(iNode,1)] * m_Polynoms(iNode,2);
            output(iNode) += vSample[m_aConnections(iNode,0)] * vSample[m_aConnections(iNode,1)] * m_Polynoms(iNode,3);
            output(iNode) += vSample[m_aConnections(iNode,0)] * vSample[m_aConnections(iNode,0)] * m_Polynoms(iNode,4);
            output(iNode) += vSample[m_aConnections(iNode,1)] * vSample[m_aConnections(iNode,1)] * m_Polynoms(iNode,5);
            output(iNode) += m_Polynoms(iNode,0);
            
            //printf("Output values: %f\n", output(iNode));
          }
        }
        
        return output;
      }

    //evaluate nodes over reals approximated by w-NIBNAF
    arma::rowvec evaluate_approx(arma::rowvec vSample)
      {
        if(!m_bIsEncoded)
        {
          printf("gmdh_net_layer.evaluate_approx: coefficients are not encoded\n");
          exit(1); 
        }

        arma::rowvec output(m_nNodes);

        for(int iNode = 0; iNode < m_nNodes; iNode++)
        {
          if(m_NodeFlags[iNode])
          {
            //printf("Evaluate node %d.\n", iNode);
            //std::cout << "Polynomial coefs: " << m_PolynomsApprox.row(iNode) << std::endl;
             
            //printf("Input values: %f,%f\n", vSample(m_aConnections(iNode,0)), m_Polynoms(iNode,1));

            output(iNode) = vSample[m_aConnections(iNode,0)] * m_PolynomsApprox(iNode,1);
            output(iNode) += vSample[m_aConnections(iNode,1)] * m_PolynomsApprox(iNode,2);
            output(iNode) += vSample[m_aConnections(iNode,0)] * vSample[m_aConnections(iNode,1)] * m_PolynomsApprox(iNode,3);
            output(iNode) += vSample[m_aConnections(iNode,0)] * vSample[m_aConnections(iNode,0)] * m_PolynomsApprox(iNode,4);
            output(iNode) += vSample[m_aConnections(iNode,1)] * vSample[m_aConnections(iNode,1)] * m_PolynomsApprox(iNode,5);
            output(iNode) += m_PolynomsApprox(iNode,0);
            
            //printf("Output values: %f\n", output(iNode));
          }
        }
        
        return output;
      }    

    //evaluate node in the plaintext space
    std::vector<params::poly_p> evaluate_plain(std::vector<params::poly_p> pSample, pk_t *pk)
      {
        if(!m_bIsEncoded)
        {
          printf("gmdh_net_layer.evaluate_plain: coefficients are not encoded\n");
          exit(1); 
        }

        std::vector<params::poly_p> output;

        for(int iNode = 0; iNode < m_nNodes; iNode++)
        {
          params::poly_p nodeOutput;

          if(m_NodeFlags[iNode])
          {
            //printf("Evaluate node %d\n", iNode);

            size_t nCoef = m_crtPolynoms[iNode].size(); 
            if (nCoef < m_Polynoms.n_cols)
            {
             printf("Evaluate poly: Number of coefs is less than %llu! %zu instead. \n", m_Polynoms.n_cols, nCoef);
             exit(1);
            }

            
            //printf("Inputs:\n");
            //print_poly(pSample[m_aConnections(iNode,0)]);
            //print_poly(pSample[m_aConnections(iNode,1)]);
            

            pSample[m_aConnections(iNode,0)].ntt_pow_phi();
            pSample[m_aConnections(iNode,1)].ntt_pow_phi();

            //printf("Coefs:\n");
            for(int iCoef = 0; iCoef < m_Polynoms.n_cols; iCoef++)
            {
              //print_poly(m_crtPolynoms[iNode][iCoef]);
              m_crtPolynoms[iNode][iCoef].ntt_pow_phi();              
            }

            nodeOutput = pSample[m_aConnections(iNode,0)] * m_crtPolynoms[iNode][1];
            nodeOutput = nodeOutput + pSample[m_aConnections(iNode,1)] * m_crtPolynoms[iNode][2];
            nodeOutput = nodeOutput + pSample[m_aConnections(iNode,0)] * pSample[m_aConnections(iNode,1)] * m_crtPolynoms[iNode][3];
            nodeOutput = nodeOutput + pSample[m_aConnections(iNode,0)] * pSample[m_aConnections(iNode,0)] * m_crtPolynoms[iNode][4];
            nodeOutput = nodeOutput + pSample[m_aConnections(iNode,1)] * pSample[m_aConnections(iNode,1)] * m_crtPolynoms[iNode][5];
            nodeOutput = nodeOutput + m_crtPolynoms[iNode][0]; //constant term

            nodeOutput.invntt_pow_invphi();

            std::array<mpz_t, params::poly_p::degree> bal_repr;
            for(size_t i = 0; i < params::poly_p::degree; i++)
            {
              mpz_inits(bal_repr[i], nullptr);
            }

            nodeOutput.poly2mpz(bal_repr);
            
            // Reduce the coefficients
            for (size_t j = 0; j < params::poly_p::degree; j++) 
            { 
              //mpz_mod(bal_repr[j], bal_repr[j], params::poly_p::moduli_product());
            }
            nodeOutput.mpz2poly(bal_repr);
            //printf("Result:\n");
            //print_poly(nodeOutput);

            //print_poly_degrees(nodeOutput);
            //std::cout << std::endl;

            for(size_t i = 0; i < params::poly_p::degree; i++)
            {
              mpz_clears(bal_repr[i], nullptr);
            }

            for(int iCoef = 0; iCoef < m_Polynoms.n_cols; iCoef++)
            {
              m_crtPolynoms[iNode][iCoef].invntt_pow_invphi();              
            }
            pSample[m_aConnections(iNode,0)].invntt_pow_invphi();
            pSample[m_aConnections(iNode,1)].invntt_pow_invphi();
            
          }

          output.push_back(nodeOutput);

        } 
        return output;
      } 

    //evaluate a layer with random polynomials (random at each time)
    std::vector<params::poly_p> evaluate_plain_random(std::vector<params::poly_p> pSample, pk_t *pk)
      {
        if(!m_bIsEncoded)
        {
          printf("gmdh_net_layer.evaluate_plain_ranodm: coefficients are not encoded\n");
          exit(1); 
        } 
        std::vector<params::poly_p> output;

        for(int iNode = 0; iNode < m_nNodes; iNode++)
        {
          params::poly_p nodeOutput;

          if(m_NodeFlags[iNode])
          {
            //printf("Evaluate node %d.\n", iNode + 1);
            std::vector<params::poly_p> crtPolynom;
            for(size_t iCoef = 0; iCoef < 6; iCoef++)
            {
              crtPolynom.push_back(random_poly(m_nIntPrec, m_nFracPrec));
            }

            pSample[m_aConnections(iNode,0)].ntt_pow_phi();
            pSample[m_aConnections(iNode,1)].ntt_pow_phi();

            for(int iCoef = 0; iCoef < 6; iCoef++)
            {
              crtPolynom[iCoef].ntt_pow_phi();              
            }

            nodeOutput = pSample[m_aConnections(iNode,0)] * crtPolynom[1];
            nodeOutput = nodeOutput + pSample[m_aConnections(iNode,1)] * crtPolynom[2];
            nodeOutput = nodeOutput + pSample[m_aConnections(iNode,0)] * pSample[m_aConnections(iNode,1)] * crtPolynom[3];
            nodeOutput = nodeOutput + pSample[m_aConnections(iNode,0)] * pSample[m_aConnections(iNode,0)] * crtPolynom[4];
            nodeOutput = nodeOutput + pSample[m_aConnections(iNode,1)] * pSample[m_aConnections(iNode,1)] * crtPolynom[5];
            nodeOutput = nodeOutput + crtPolynom[0];

            nodeOutput.invntt_pow_invphi();

            std::array<mpz_t, params::poly_p::degree> bal_repr;
            for(size_t i = 0; i < params::poly_p::degree; i++)
            {
              mpz_inits(bal_repr[i], nullptr);
            }

            nodeOutput.poly2mpz(bal_repr);
            
            // Reduce the coefficients
            for (size_t j = 0; j < params::poly_p::degree; j++) 
            {
              mpz_mod(bal_repr[j], bal_repr[j], params::poly_p::moduli_product());
            }

            nodeOutput.mpz2poly(bal_repr);

            for(size_t i = 0; i < params::poly_p::degree; i++)
            {
              mpz_clears(bal_repr[i], nullptr);
            }
            pSample[m_aConnections(iNode,0)].invntt_pow_invphi();
            pSample[m_aConnections(iNode,1)].invntt_pow_invphi();
          }

          output.push_back(nodeOutput);
        } 
        return output;
      }    
  
    bool IsNodeUsed(int iNode)
      {
        if (iNode > m_nNodes || iNode < 0)
        {
          printf("Invalid node is ");
        }
        return m_NodeFlags[iNode];
      }
  };

class gmdh_net
  {
    //number of input nodes
    size_t m_nInputs;

    //number of layers where polynomials evaluated (i.e. without input layer)
    size_t m_nLayers;

    //number of nodes in each layer
    std::vector<size_t> m_NumLayerNodes;

    //layers
    std::vector<gmdh_net_layer> m_aLayers;

    //total number of samples
    size_t m_nSamples;

    //amount of train and test samples
    size_t m_nTrainSamples;
    size_t m_nTestSamples;

    //input dataset
    arma::mat m_InputData;
    double m_dMaxValue;
    double m_dMinValue;
    
    //split the real output into training and test sets
    arma::mat m_RealOutputDataTrain;
    arma::mat m_RealOutputDataTest;

    //output of the test set
    arma::mat m_OutputDataTest;    

    //plaintext space modulus
    mpz_class m_mpzModulus;

    //secret and public keys corresponding to the plaintext modulus (other parameters are global)
    sk_t *m_sk;
    pk_t *m_pk;

    //precision for polynomial coefficients
    size_t m_nIntPrec;
    size_t m_nFracPrec;

    //state of the network
    bool m_bIsTrained;

  public:
    gmdh_net(): m_nInputs(0), m_nLayers(0), m_nSamples(0), m_dMaxValue(-1.0),m_dMinValue(std::numeric_limits<double>::max()), m_sk(nullptr), m_pk(nullptr), m_bIsTrained(false){}

    gmdh_net(size_t const nLayers, std::vector<gmdh_net_layer> const &aLayers, mpz_class const mpzModulus, sk_t &sk, pk_t &pk, size_t nIntPrec, size_t nFracPrec): m_nLayers(nLayers), m_mpzModulus(mpzModulus), m_sk(&sk), m_pk(&pk), m_nIntPrec(nIntPrec), m_nFracPrec(nFracPrec),m_bIsTrained(false)
      {
        m_aLayers.clear();
        for (size_t i = 0; i < aLayers.size(); i++)
        {
          m_aLayers.push_back(aLayers[i]);
        }
      }

    void read_params(char* net_filename)
      {
        std::ifstream net_file(net_filename);
        std::string line;

        if(!net_file.is_open())
        {
          std::cout << "Unable to open a file." << std::endl;
          exit(1);
        }

        getline(net_file, line);
        std::string s("Inputs ");
        if(line.find(s) == std::string::npos)
        {
          printf("Number of inputs is undefined\n");
          exit(1);
        }
        line.erase(0, s.length());
        m_nInputs = std::stoi(line);
        printf("Number of inputs %zu\n", m_nInputs);

        getline(net_file, line);
        s = "Layers ";
        if(line.find(s) == std::string::npos)
        {
          printf("Number of layers is undefined\n");
          exit(1);
        }
        line.erase(0, s.length());
        m_nLayers = std::stoi(line);
        printf("Number of layers %zu\n", m_nLayers);
        
        m_aLayers.clear();
        m_NumLayerNodes.clear();

        bool bSkip = false;

        for(int iLayer = 0; iLayer < m_nLayers; iLayer++)
        {
          //number of nodes in a layer
          int nNodes;
          //active nodes
          std::vector<size_t> nodesToRemain;

          if(!bSkip)
            getline(net_file, line);
          std::string sLayer("Layer ");
          sLayer += std::to_string(iLayer);
          if(line.find(sLayer) == std::string::npos)
          {
            std::cout << sLayer << " is not found" << std::endl;
            exit(1);
          }
          bSkip = false;
          std::cout << sLayer << std::endl;

          getline(net_file, line);
          s = "Nodes ";
          if(line.find(s) == std::string::npos)
          {
            printf("Number of nodes is not found\n");
            exit(1);
          }
          line.erase(0, s.length());
          nNodes = std::stoi(line);
          m_NumLayerNodes.push_back(nNodes);
          printf("Number of nodes %d\n", nNodes);

          //wiring of nodes
          arma::mat incomingNodes(nNodes, 2, arma::fill::zeros);
          //node polynomials
          arma::mat nodePolys(nNodes, 6, arma::fill::zeros);
          //node regularization parameter
          arma::vec nodeAlphas(nNodes, arma::fill::zeros);
          
          for (int iNode = 0; iNode < nNodes; iNode++)
          {
            if (!bSkip)
              getline(net_file, line);
            std::string sNode("Node ");
            sNode += std::to_string(iNode);
            if(line.find(sNode) == std::string::npos)
            {
              bSkip = true;
              continue;
            }
            else
              bSkip = false;
            
            nodesToRemain.push_back(iNode);
            std::cout << sNode << std::endl;

            getline(net_file, line);
            s = "Alpha ";
            if(line.find(s) == std::string::npos)
            {
              printf("Regularization parameter is not found\n");
              exit(1);
            }
            line.erase(0, s.length());
            nodeAlphas(iNode) = std::stod(line);
            printf("Regularization parameter is %f\n", nodeAlphas(iNode));

            getline(net_file, line);
            s = "Input_1 ";
            if(line.find(s) == std::string::npos)
            {
              printf("Input 1 is not found\n");
              exit(1);
            }
            line.erase(0, s.length());
            incomingNodes(iNode, 0) = std::stoi(line);
            printf("Input 1 is %f\n", incomingNodes(iNode, 0));

            getline(net_file, line);
            s = "Input_2 ";
            if(line.find(s) == std::string::npos)
            {
              printf("Input 2 is not found\n");
              exit(1);
            }
            line.erase(0, s.length());
            incomingNodes(iNode, 1) = std::stoi(line);
            printf("Input 2 is %f\n", incomingNodes(iNode, 1));

            getline(net_file, line);
            s = "Poly ";
            if(line.find(s) == std::string::npos)
            {
              printf("Polynomial coefficients are not found\n");
              exit(1);
            }
            line.erase(0, s.length());
            for(int iCoef = 0; iCoef < nodePolys.n_cols; iCoef++)
            {
              if(line.empty())
              {
                printf("Coefficient %d is not found\n", iCoef);
                exit(1);
              }
              std::string::size_type last_coef_pos;
              nodePolys(iNode, iCoef) = std::stod(line, &last_coef_pos);
              line.erase(0, last_coef_pos + 1);
            }
            std::cout << "Polynomial: " << nodePolys.row(iNode) << std::endl;
          }

          gmdh_net_layer layer(nNodes, incomingNodes, nodePolys, nodeAlphas, m_mpzModulus);
          layer.update_nodes(nodesToRemain);
          m_aLayers.push_back(layer);
        }
      }

    void set_layer_nodes(std::vector<size_t> const numLayerNodes)
      {
        m_NumLayerNodes.clear();
        for(size_t i = 0; i < numLayerNodes.size(); i++)
        {
          m_NumLayerNodes.push_back(numLayerNodes[i]);
        }
        m_nLayers = m_NumLayerNodes.size();
      }

    void set_input_amount(int nNodes)
      {
        m_nInputs = nNodes;
      }

    void set_modulus(mpz_class const mpzModulus)
      {
        m_mpzModulus = mpzModulus;

        for(int iLayer = 0; iLayer < m_nLayers; iLayer++)
        {
          m_aLayers[iLayer].set_modulus(mpzModulus);
        }
      }

    void set_keys(sk_t &sk, pk_t &pk)
      {
        m_sk = &sk;
        m_pk = &pk;
      }

    void set_layers(std::vector<gmdh_net_layer> aLayers)
      {
        m_aLayers.clear();
        m_nLayers = aLayers.size();
        for (size_t i = 0; i < m_nLayers; i++)
        {
          aLayers[i].set_modulus(m_mpzModulus);
          m_aLayers.push_back(aLayers[i]);
        }
      }

    void set_precisions(double approx_error)
      {
        if(!m_bIsTrained)
        {
          printf("gmdh_net.set_precisions: the network is not trained\n");
          exit(1);
        }

        double base = get_base(nWindow);

        m_nIntPrec = int_bits(get_max_abs_coef());
        m_nFracPrec = size_t(-floor(log(approx_error) / log(base)));

        for(int iLayer = 0; iLayer < m_nLayers; iLayer++)
        {
          m_aLayers[iLayer].encode_coefs(m_nIntPrec, m_nFracPrec);
        }
      }

    //evaluate nodes in the homomorphic mode
    FV::ciphertext_t evaluate(std::vector<FV::ciphertext_t>& cSample)
      {
        std::vector<FV::ciphertext_t> prevLayerOutput;
        std::vector<FV::ciphertext_t> curLayerOutput;

        prevLayerOutput = cSample;
        for (int iLayer = 0; iLayer < m_nLayers; iLayer++)
        {
          //printf("Evaluate layer %d.\n", iLayer + 1);
          //take a matrix from a layer
          curLayerOutput = m_aLayers[iLayer].evaluate_enc(prevLayerOutput, m_pk, m_sk);

          prevLayerOutput.clear();
          prevLayerOutput = curLayerOutput;
        }
        return prevLayerOutput[0];
      }

    //evaluate nodes in the homomorphic mode via the Sujoy's hardware unit
    FV::ciphertext_t evaluate_suj(std::vector<FV::ciphertext_t>& cSample)
      {
        std::vector<FV::ciphertext_t> prevLayerOutput;
        std::vector<FV::ciphertext_t> curLayerOutput;

        prevLayerOutput = cSample;
        for (int iLayer = 0; iLayer < m_nLayers; iLayer++)
        {
          //printf("Evaluate layer %d.\n", iLayer + 1);
          //take a matrix from a layer
          curLayerOutput = m_aLayers[iLayer].evaluate_suj(prevLayerOutput, m_pk, m_sk);

          prevLayerOutput.clear();
          prevLayerOutput = curLayerOutput;
        }
        return prevLayerOutput[0];
      }  

    //evaluate nodes in the plaintext space
    params::poly_p evaluate_plain(std::vector<params::poly_p>& vSample)
      {
        std::vector<params::poly_p> prevLayerOutput;

        for (size_t i = 0; i < vSample.size(); i++)
        {
          prevLayerOutput.push_back(vSample[i]);  
        }
        
        for (int iLayer = 0; iLayer < m_nLayers; iLayer++)
        {
          printf("Evaluate layer %d.\n", iLayer);
          //take a matrix from a layer
          std::vector<params::poly_p> curLayerOutput;
          curLayerOutput = m_aLayers[iLayer].evaluate_plain(prevLayerOutput, m_pk);

          prevLayerOutput.clear();
          for(size_t j = 0; j < curLayerOutput.size(); j++)
          {
            prevLayerOutput.push_back(curLayerOutput[j]);
          }
        }
        return prevLayerOutput[0];    
      }

    //evaluate nodes in the plaintext space with random network coefficients
    params::poly_p evaluate_plain_random(std::vector<params::poly_p>& vSample)
      {
        std::vector<params::poly_p> prevLayerOutput;

        for (size_t i = 0; i < vSample.size(); i++)
        {
          prevLayerOutput.push_back(vSample[i]);  
        }
        
        for (int iLayer = 0; iLayer < m_nLayers; iLayer++)
        {
          //printf("Evaluate layer %d.\n", i + 1);
          //take a matrix from a layer
          std::vector<params::poly_p> curLayerOutput;
          curLayerOutput = m_aLayers[iLayer].evaluate_plain_random(prevLayerOutput, m_pk);

          prevLayerOutput.clear();
          for(size_t j = 0; j < curLayerOutput.size(); j++)
          {
            prevLayerOutput.push_back(curLayerOutput[j]);
          }
        }
        return prevLayerOutput[0];    
      }  

    //evaluate nodes in the real domain
    double evaluate_double(arma::rowvec vSample)
      {
        arma::rowvec prevLayerOutput;

        prevLayerOutput = vSample;
        for (int iLayer = 0; iLayer < m_nLayers; iLayer++)
        {
          //printf("Evaluate layer %d.\n", iLayer + 1);
          arma::rowvec curLayerOutput(m_aLayers[iLayer].evaluate_double(prevLayerOutput));
          
          prevLayerOutput = curLayerOutput;
        }

        return prevLayerOutput(0);    
      }

    //evaluate a file in the real domain
    void evaluate_file_double(char* data_filename, int skipLines = 0)
      {
        printf("Evaluating file %s\n", data_filename);
        std::ifstream data_file(data_filename);
        std::string line;

        if(!data_file.is_open())
        {
          std::cout << "Unable to open a file." << std::endl;
          exit(1);
        }

        //total number of samples in a file
        int nSamples = 0;
        while(getline(data_file, line))
        {
          nSamples++;
        }
          
        data_file.clear();
        data_file.seekg(0, std::ios_base::beg);

        int iSample = 0;
        arma::mat inputData(nSamples - skipLines, m_nInputs);
        arma::mat realOutputData(nSamples - skipLines, 1);
        arma::mat outputData(nSamples - skipLines, 1);

        while(getline(data_file, line))
        {
          if (iSample < skipLines)
          {
            iSample++;
            continue;
          }
          int iCol = 0;
          std::string::size_type last_pos;

          while(!line.empty())
          {
            //srand(time(NULL));

            double cur_value = std::stod(line, &last_pos) / scalar; //data scaled
            double abs_cur_value = fabs(cur_value); //absolute value of a data value to find a bit range

            m_dMinValue = (abs_cur_value < m_dMinValue)? abs_cur_value: m_dMinValue;
            m_dMaxValue = (abs_cur_value > m_dMaxValue)? abs_cur_value: m_dMaxValue;

            if(iCol < m_nInputs) 
            {
              inputData(iSample - skipLines, iCol) = cur_value;
            }
            if(iCol == m_nInputs)
            {
              realOutputData(iSample - skipLines, 0) = cur_value;
            } 
            line.erase(0, last_pos + 1);
            iCol++; 
          }
          outputData(iSample - skipLines, 0) = evaluate_double(inputData.row(iSample - skipLines));

          iSample++;
        }
        data_file.close();

        std::cout << "MSE: " << mse(outputData, realOutputData) << std::endl;
        std::cout << "MAPE: " << mape(outputData, realOutputData) << std::endl;
      }
  
    //evaluate nodes over reals approximated by w-NIBNAF
    double evaluate_approx(arma::rowvec vSample)
      {

        arma::rowvec prevLayerOutput;

        prevLayerOutput = vSample;
        for (int iLayer = 0; iLayer < m_nLayers; iLayer++)
        {
          //printf("Evaluate layer %d.\n", iLayer + 1);
          arma::rowvec curLayerOutput(m_aLayers[iLayer].evaluate_approx(prevLayerOutput));
          
          prevLayerOutput = curLayerOutput;
        }

        return prevLayerOutput(0);    
      }

    //load data file and form input and output
    void get_data(char* data_filename)
      {
        printf("Get data...\n");
        std::ifstream data_file(data_filename);
        std::string line;

        if(data_file.is_open())
        {
          int iSample = 0;
          while(getline(data_file, line))
          {
            iSample++;
          }

          //set total number of samples
          m_nSamples = iSample;
          
          data_file.clear();
          data_file.seekg(0, std::ios_base::beg);
        }
        else
        {
          std::cout << "Unable to open a file." << std::endl;
          exit(1); 
        }

        m_InputData = arma::mat(m_nSamples, m_nInputs);

        arma::mat m_RealOutputData(m_nSamples, 1);

        if(data_file.is_open())
        {
          int iSample = 0;
          while(getline(data_file, line))
          {
            int iCol = 0;
            std::string::size_type last_pos;

            while(!line.empty())
            {
              //srand(time(NULL));

              double cur_value = std::stod(line, &last_pos) / scalar; //data scaled
              double abs_cur_value = fabs(cur_value); //absolute value of a data value to find a bit range

              m_dMinValue = (abs_cur_value < m_dMinValue)? abs_cur_value: m_dMinValue;
              m_dMaxValue = (abs_cur_value > m_dMaxValue)? abs_cur_value: m_dMaxValue;

              if(iCol < m_nInputs) 
              {
                m_InputData(iSample, iCol) = cur_value;
              }
              if(iCol == m_nInputs)
              {
                m_RealOutputData(iSample, 0) = cur_value;
              } 
              line.erase(0, last_pos + 1);
              iCol++; 
            }
            iSample++; 
          }

          //split the data into training and test set according to the ratio 2:1
          m_nTrainSamples = 2 * m_nSamples / 3;
          m_nTestSamples = m_nSamples / 3;           

          m_RealOutputDataTrain = m_RealOutputData.submat(0, 0, m_nTrainSamples - 1, 0);
          m_RealOutputDataTest = m_RealOutputData.submat(m_nTrainSamples, 0, m_nSamples - 1, 0);

          printf("Number of training samples: %zu\n", m_nTrainSamples);
          printf("Number of test samples: %zu\n", m_nTestSamples);

          data_file.close();
        }
        else
        {
          std::cout << "Unable to open a file." << std::endl;
        }
      }

    //construct a new layer
    gmdh_net_layer construct_layer(size_t const iLayer)
      {
        if(iLayer >= m_nLayers)
        {
          printf("The maximal number of layers is exceeded!\n");
          exit(1);
        }

        arma::mat layerInput;
        if(iLayer == 0)
        {
          layerInput = m_InputData;
        }
        else
        {
          layerInput = m_aLayers[iLayer - 1].get_output();
        }

        const int inputSize = layerInput.n_cols;

        //input matrix of the linear regression problem        
        arma::mat Xtrain(m_nTrainSamples, 6);

        //test input 
        arma::mat Xtest(m_nTestSamples, 6);

        //error matrix for node selection
        arma::vec nodeErrors(m_NumLayerNodes[iLayer]);
        nodeErrors.fill(100000000.0);
        //index of the worst node in a layer
        size_t max_error_node_ind = 0;

        //wiring of nodes
        arma::mat incomingNodes(m_NumLayerNodes[iLayer], 2);

        //node polynomials
        arma::mat nodePolys(m_NumLayerNodes[iLayer], 6);

        //layer output
        arma::mat layerOutput(m_nSamples, m_NumLayerNodes[iLayer]);

        //node regularization parameter
        arma::vec nodeAlphas(m_NumLayerNodes[iLayer]);

        for(int k = 0; k < m_nTrainSamples; k++)
        {
          Xtrain(k, 0) = 1.0;
        }
        for(int k = 0; k < m_nTestSamples; k++)
        {
          Xtest(k, 0) = 1.0;
        }

        //check all pairs of input parameters
        for(size_t i = 0; i < inputSize - 1; i++)
        {
          //form the input matrix of the linear regression problem
          for(int k = 0; k < m_nTrainSamples; k++)
          {
            Xtrain(k, 1) = layerInput(k,i);
            Xtrain(k, 4) = layerInput(k,i) * layerInput(k,i);
          }
          for(int k = 0; k < m_nTestSamples; k++)
          {
            Xtest(k, 1) = layerInput(k + m_nTrainSamples, i);
            Xtest(k, 4) = layerInput(k + m_nTrainSamples, i) * layerInput(k + m_nTrainSamples, i);
          }
          for(size_t j = i + 1; j < inputSize; j++)
          {
            //printf("Check node %zu with node %zu\n", i, j);
            //form the input matrix of the linear regression problem
            for(int k = 0; k < m_nTrainSamples; k++)
            {  
              Xtrain(k, 2) = layerInput(k, j);
              Xtrain(k, 3) = layerInput(k, i) * layerInput(k, j);
              Xtrain(k, 5) = layerInput(k, j) * layerInput(k, j);
            }
            for(int k = 0; k < m_nTestSamples; k++)
            {  
              Xtest(k, 2) = layerInput(k + m_nTrainSamples, j);
              Xtest(k, 3) = layerInput(k + m_nTrainSamples, i) * layerInput(k + m_nTrainSamples, j);
              Xtest(k, 5) = layerInput(k + m_nTrainSamples, j) * layerInput(k + m_nTrainSamples, j);
            }

            //regularization parameters of linear regression
            const int nAlphas = 11;
            double alpha[nAlphas];            

            //precomputed heavy matrix calculations
            arma::mat Xt(arma::trans(Xtrain));
            arma::mat XtX(Xt * Xtrain);
            arma::mat XtY(Xt * m_RealOutputDataTrain);

            double min_alpha_error = 100000000.0;
            double min_alpha = 0.0;
            arma::mat minAlphaPolynom;
            arma::mat minAlphaNodeOutput;

            for (int iAlpha = 0; iAlpha < nAlphas; iAlpha++)
            {
              //regularization parameters of linear regression
              alpha[iAlpha] = pow(10.0, (iAlpha - 5) * 1.0 / pow(scalar, 2.0));

              //perform the formula (X^t X + alpha * I)^(-1) X^t Y to get coefficients over the training set using different regularization parameters
              arma::mat polynom(arma::inv(XtX + alpha[iAlpha] * arma::eye(6,6)) * XtY);

              //find outcome of the node using the test set
              arma::mat nodeOutput(Xtest * polynom);
              
              //find the MSE of the node output
              double error = mse(nodeOutput, m_RealOutputDataTest);

              if (error < min_alpha_error)
              {
                min_alpha_error = error;
                min_alpha = alpha[iAlpha];
                minAlphaPolynom = polynom;
                minAlphaNodeOutput =  arma::join_cols(Xtrain * polynom, nodeOutput);
              }
            }

            //compare min_alpha_error among nodes and choose best m_NumLayerNodes[iLayer] ones
            if (min_alpha_error < nodeErrors[max_error_node_ind])
            {
              nodeErrors(max_error_node_ind) = min_alpha_error;
              nodeAlphas(max_error_node_ind) = min_alpha;

              incomingNodes(max_error_node_ind, 0) = i;
              incomingNodes(max_error_node_ind, 1) = j;

              for(int k = 0; k < 6; k++)
              {
                nodePolys(max_error_node_ind, k) = minAlphaPolynom(k, 0);  
              }

              for(int k = 0; k < m_nSamples; k++)
                {
                  layerOutput(k, max_error_node_ind) = minAlphaNodeOutput(k, 0);
                }
              

              max_error_node_ind = nodeErrors.index_max();
            }            
          }
        }
        gmdh_net_layer newLayer(m_NumLayerNodes[iLayer], incomingNodes, nodePolys, layerOutput, nodeErrors.index_min(), nodeErrors, nodeAlphas, m_mpzModulus);

        return newLayer;
      }

    //construct a neural network
    void train()
      {
        printf("Train...\n");
        m_aLayers.clear();

        float min_error = 100000000.0;
        size_t min_index = 0;

        for(int iLayer = 0; iLayer < m_nLayers; iLayer++)
        {
          //construct a layer and get the minimal error among its nodes and the corresponding index of that node
          gmdh_net_layer layer = construct_layer(iLayer);
          
          if (layer.get_min_error() < min_error)
          {
            min_error = layer.get_min_error();
            min_index = layer.get_min_error_node();
            m_aLayers.push_back(layer);

            if(iLayer == (m_nLayers - 1))
              {
                std::vector<size_t> nodesToRemain;
                for(int prevLayer = iLayer; prevLayer >= 1; prevLayer--)
                  {
                    nodesToRemain = m_aLayers[prevLayer].get_input_nodes();
                    m_aLayers[prevLayer - 1].update_nodes(nodesToRemain);
                  } 
              }
            m_OutputDataTest = m_aLayers[iLayer].get_output().rows(m_nTrainSamples, m_nSamples - 1);
            printf("Layer %d is created.\n", iLayer);
          }
          else
          {
            //output the best node from the previous layer. It will be the final output
            //set the last layer as an output one with only one node
            std::vector<size_t> nodesToRemain;
            nodesToRemain.push_back(min_index); 
            m_aLayers[iLayer - 1].update_nodes(nodesToRemain);            

            //update number of nodes needed for evaluation going backwards
            for(int prevLayer = iLayer - 1; prevLayer > 0; prevLayer--)
            {
              nodesToRemain = m_aLayers[prevLayer].get_input_nodes();
              m_aLayers[prevLayer - 1].update_nodes(nodesToRemain);
            }
            if(iLayer < m_nLayers)
            {
              m_nLayers = iLayer;
              //exit(1);  //uncomment for any number of layers gotten after training
            }

            break;
          }
        }
        m_bIsTrained = true;
      }

    //linear regression
    void lin_regression()
      {
        printf("Linear regression...\n");

        //input matrix of the linear regression problem        
        arma::mat Xtrain(m_nTrainSamples, m_nInputs + 1);

        //test input 
        arma::mat Xtest(m_nTestSamples, m_nInputs + 1);

        for (int i = 0; i < m_nTrainSamples; i++)
        {
          for (int j = 0; j < m_nInputs; j++)
          {
            Xtrain(i,j) = m_InputData(i, j);
          }
          Xtrain(i, m_nInputs) = 1.0;
        }

        for (int i = 0; i < m_nTestSamples; i++)
        {
          for (int j = 0; j < m_nInputs; j++)
          {
            Xtest(i,j) = m_InputData(i + m_nTrainSamples, j);
          }
          Xtest(i, m_nInputs) = 1.0;
        }

        //coefficients of regression
        arma::mat coefs(m_nInputs + 1, 1);           

        //precomputed heavy matrix calculations
        arma::mat Xt(arma::trans(Xtrain));
        arma::mat XtX(Xt * Xtrain);
        arma::mat XtY(Xt * m_RealOutputDataTrain);

        double min_alpha_error = 100000000.0;
        double min_alpha = 0.0;
        double min_mape = 0.0;
        arma::mat minAlphaPolynom;

        //number of regularization parameters
        int nAlphas = 11;
        double alpha;

        for (int iAlpha = 0; iAlpha < nAlphas; iAlpha++)
        {
          //regularization parameters of linear regression
          alpha = pow(10.0, (iAlpha - 5) * 1.0 / pow(scalar, 2.0));

          //perform the formula (X^t X + alpha * I)^(-1) X^t Y to get coefficients over the training set using different regularization parameters
          arma::mat polynom(arma::inv(XtX + alpha * arma::eye(m_nInputs + 1, m_nInputs + 1)) * XtY);

          //find outcome of the node using the test set
          arma::mat output(Xtest * polynom);
          
          //find the MSE of the node output
          double error = mse(output, m_RealOutputDataTest);

          if (error < min_alpha_error)
          {
            min_alpha_error = error;
            min_mape = mape(output, m_RealOutputDataTest);
            min_alpha = alpha;
            minAlphaPolynom = polynom;
          }
        }
        std::cout << "Coefficients:" << std::endl << minAlphaPolynom << std::endl;

        printf("MSE: %f\n", min_alpha_error);
        printf("MAPE: %f\n", min_mape);

      }

    //naive prediction where the predictied value is equal to the last measurement done
    void naive_prediction()
      {
        printf("Naive prediction: \n");

        arma::mat output(m_nTestSamples, 1);
        for (int i = 0; i < m_nTestSamples; i++)
        {
          output(i) = m_InputData(m_nTrainSamples + i, 47);
        }

        printf("MSE: %f\n", mse(output, m_RealOutputDataTest));
        printf("MAPE: %f\n", mape(output, m_RealOutputDataTest));
      }

    //get the maximal absolute value of network coefficients
    double get_max_abs_coef() const
      {
        if(!m_bIsTrained)
        {
          printf("get_max_abs_coef: the network is not trained\n");
          exit(1);
        }
        double res;
        double tmp;
        for(int iLayer = 0; iLayer < m_nLayers; iLayer++)
        {
          tmp = m_aLayers[iLayer].get_max_abs_coef();
          if  (tmp > res)
          {
            res = tmp;
          }
        }

        return res;
      }

    //show the network structure
    void print_layers() const
      {
        printf("Network structure: \n");
        printf("Number of layers: %zu\n\n", m_nLayers);
        for(int iLayer = 0; iLayer < m_nLayers; iLayer++)
        {
          printf("Layer %d\n", iLayer);
          m_aLayers[iLayer].print();
        }
      }

    //print layers encoded by w-NIBNAF
    void print_layers_encoded() const
      {
        for(size_t iLayer = 0; iLayer < m_nLayers; iLayer++)
        {
          printf("Layer %zu\n", iLayer);
          m_aLayers[iLayer].print_encodings();
        }
      }

    //get number of test samples
    size_t get_num_test_samples() const
      {
        return m_nTestSamples;
      }

    //get a number of input nodes
    size_t get_input_nodes() const
      {
        return m_nInputs;
      }

    arma::mat get_test_input() const
      {
        return m_InputData.rows(m_nTrainSamples, m_nSamples - 1);
      }

    arma::mat get_test_output() const
      {
        return m_RealOutputDataTest;
      }

    //get minimal data value
    double get_min_value() const
      {
        return m_dMinValue;
      }

    //get maximal data value
    double get_max_value() const
      {
        return m_dMaxValue;
      }

    arma::mat get_net_output() const
      {
        return m_OutputDataTest;
      }
  
    void get_poly_bit_range(size_t& intPart, size_t& fracPart)
      {
        intPart = m_nIntPrec;
        fracPart = m_nFracPrec;
      }
  };


params::poly_p read_poly_from_file(char* filename)
  {
      std::ifstream file(filename);
      std::string line;

	printf("file name %s\n", filename);
      if(!file.is_open())
      {
        std::cout << "Unable to open a file." << std::endl;
        exit(1);
      }

      std::array<mpz_t, params::poly_p::degree> poly_array;
      params::poly_p poly;
      for (size_t i = 0; i < params::poly_p::degree; i++)
      {
        mpz_inits(poly_array[i], nullptr);
      }
      size_t index = 0;
      while (getline(file,line))
      {
        mpz_set_str(poly_array[index], line.c_str(), 10);
        //std::cout << index << " " << poly_array[index] << std::endl;
        index++;
      }
      poly.mpz2poly(poly_array);
      for (size_t i = 0; i < params::poly_p::degree; i++)
      {
        mpz_clears(poly_array[i], nullptr);
      }
      
      return poly;
  }

int main() {
 
  srand (1234);
  compute_barrett_constants();
  compute_crt_constants();
  creat_primrt_array( );
  compute_pby_t();
  read_keys();
  
  HW_INIT_HW();

  printf("System initialized\n");

  //switch for different algorithm modes
  bool bCipherMode = true;
  bool bPlainMode = true;
  bool bWriteCoefs = false;

  for(int iWindow = 950; iWindow < 951; iWindow++) {
    //gap of w-NIBNAF
    nWindow = iWindow;
    //precisions for input values and network polynomial coefficients
    printf("w: %d\n", nWindow);

    //w-NIBNAF base
    double base = get_base(nWindow);
    printf("base: %f\n", base);

    //global scalar
    //scalar = pow(get_base(nWindow),32.0);

    //create a network
    gmdh_net net;

    //number of nodes in the input layer
    const size_t nInputNodes = 51;

    //max degree of polynomials in R_q and R_t
    const size_t d = params::poly_t::degree;

    //assign number of input nodes
    net.set_input_amount(nInputNodes);

    //assign number of nodes at each layer
    std::vector<size_t> layerNodes;
    layerNodes.push_back(8);
    layerNodes.push_back(4);
    layerNodes.push_back(2);
    layerNodes.push_back(1);
    net.set_layer_nodes(layerNodes);

    //data filename
    char data_filename[] = "data.txt";

    //load data into the network
    net.get_data(data_filename);

    //approximation error
    double inputApproxError = 1.0;
    double polyApproxError = 0.020426459400003687;

    //bit range for input data
    printf("Max data value: %f\n", net.get_max_value());
    size_t nInputIntPrec = int_bits(net.get_max_value());
    size_t nInputFracPrec = size_t(-floor(log(inputApproxError) / log(base)));

    //naive prediction
    net.naive_prediction();

    //linear regression
    net.lin_regression();

    //train the network
    net.train();

    //print neural network structure
    net.print_layers();

    //set network precisions
    net.set_precisions(polyApproxError);

    //bit range for network coefficients
    size_t nPolyIntPrec;
    size_t nPolyFracPrec;
    net.get_poly_bit_range(nPolyIntPrec, nPolyFracPrec);

    printf("Input precs: %zu, %zu\n", nInputIntPrec, nInputFracPrec);
    printf("Poly precs: %zu, %zu\n", nPolyIntPrec, nPolyFracPrec);

    printf("Coefs: %d\n", int(ceil(fmax(nInputIntPrec * 1.0 / nWindow, (nPolyIntPrec + nPolyFracPrec) * 1.0 / nWindow))));

    /*
    if (fmax(nInputIntPrec/iWindow, (nPolyIntPrec + nPolyFracPrec)/iWindow) < 1.0)
    {
      break;
    }
    */

    //index of coefficient where to split integral and fractional part
    if(nWindow >= 1)
    {
      cut_point = 385;
    }
    else
    {
      size_t n_int_bits = int(pow(2, layerNodes.size())) * (nInputIntPrec - 1) + (int(pow(2, layerNodes.size())) - 1) * (nPolyIntPrec - 1) + 1;
      size_t n_frac_bits = int(pow(2, layerNodes.size())) * nInputFracPrec + (int(pow(2, layerNodes.size())) - 1) * nPolyFracPrec;
      cut_point = (d - n_frac_bits + n_int_bits)/2;
      printf("Sum of bits: %zu\n", n_int_bits + n_frac_bits);
      printf("Cut point: %zu\n", cut_point);

      if((cut_point > d-1) || (n_int_bits + n_frac_bits > d))
      {
        printf("Wrong cut point!\n");
        exit(1);
        //cut_point = d/2;
      }
    }

    printf("Cut point: %zu\n", cut_point);

    //cut point for initial encodings
    cut_point_init = (d - std::max(nInputFracPrec, nPolyFracPrec) + std::max(nInputIntPrec, nPolyIntPrec)) / 2;

    //net output of the test set
    arma::mat output_net_double = net.get_net_output();

    //expected output
    arma::mat output_real = arma::mat(net.get_test_output());

    std::cout << "MSE: " << mse(output_net_double, output_real) << std::endl;
    std::cout << "MAPE: " << mape(output_net_double, output_real) << std::endl;

    //print encoded polynomial coefficients
    net.print_layers_encoded();

    //evaluate file
    //char validation_file[] = "data/data_1000_1002_1016_1018_1023_1047_1059_1067-1068_1087.txt";
    //net.evaluate_file_double(validation_file);

    //just train
    //exit(0);    

    if(!bCipherMode && !bPlainMode)
      return 0;

    //output array in the encrypted, real and plain form
    arma::vec output_net_enc;
    arma::vec output_net_plain;
    //floating point output with approximations made while working with w-NIBNAF
    arma::vec output_net_approx;
    
    if(bCipherMode)
      output_net_enc = arma::vec(net.get_num_test_samples());
    if(bPlainMode)
    {
      output_net_plain = arma::vec(net.get_num_test_samples());
      output_net_approx = arma::vec(net.get_num_test_samples());
    }

    double total_time = 0.0;

    //create a file to store coefficients
    std::ofstream fout;
    if(bWriteCoefs)
    {
      //define an array to contain polynomial coefficients per run
      std::string s = std::to_string(nWindow);
      const char* wstring = s.c_str();

      char coefs_file[15];
      std::strcpy(coefs_file, wstring);
      std::strcat(coefs_file, "-coefs.txt");

      fout.open(coefs_file);
    }

    size_t nTestSamples = net.get_num_test_samples();


    //without SIMD packing
    double max_error = 0.0;
    double min_error = 100000.0;

    size_t max_error_ind = -1;
    size_t min_error_ind = -1;

    int counter_eval=0;

    for(size_t iSample = 0; iSample < nTestSamples; iSample++)
    { 
      //time start for one run of the algorithm
      auto start = std::chrono::system_clock::now();
    
      // if(counter_eval==2) break;
      // counter_eval++;


      mpf_class res_f;
      if(bCipherMode)
      {
        //output in the CRT form
        std::array<params::poly_p, nPltxtModuli> poly_crt_res;

        //loop for every modulus
        for(int i = 0; i < nPltxtModuli; i++)
        {
          //time start for one modulus
          auto start_one_mod = std::chrono::system_clock::now();
          
          
          //initialize a neural network
          mpz_class curModulus = mpz_class(plaintextModuli[i]);
          params::plaintextModulus<mpz_class>::value_mpz = curModulus;

          //generate keys
          params::poly_p sk_poly = read_poly_from_file("keys/sk");
          sk_t sk(sk_poly);
          params::poly_p evk_polys[4];
          evk_polys[0] = read_poly_from_file("keys/rlk0_0");
          evk_polys[1] = read_poly_from_file("keys/rlk0_1");
          evk_polys[2] = read_poly_from_file("keys/rlk1_0");
          evk_polys[3] = read_poly_from_file("keys/rlk1_1");
          evk_t evk(evk_polys, 91);
          params::poly_p pk_polys[2];
          pk_polys[0] = read_poly_from_file("keys/pk0");
          pk_polys[1] = read_poly_from_file("keys/pk1");
          pk_t pk(sk, evk, pk_polys);

          //set the current modulus, sk, pk to the net
          net.set_modulus(curModulus);
          net.set_keys(sk, pk);
          
          //convert data to CRT
          std::vector<FV::ciphertext_t> vSample;

          for(int k = 0; k < nInputNodes; k++)
          {
            //std::cout << "Current input node: " << k+1 << std::endl;
            params::poly_p tmpPoly;
            //convert to balanced ternary expansion and then to a corresponding polynomial
            convert_to_crt_one_modulus(tmpPoly, net.get_test_input()(iSample, k), nInputIntPrec, nInputFracPrec);

            //encrypt data
            FV::ciphertext_t c;
            FV::encrypt_poly(c, pk, tmpPoly);

            vSample.push_back(c);
          }

          //evaluate a neural network in the encrypted mode
          FV::ciphertext_t c_res;
          c_res = net.evaluate_suj(vSample);

          //noise
          int noiseBits = poly_noise(sk, pk, c_res);

          if(noiseBits > pk.noise_max)
          {
            std::cout << "OVERFLOW!" << std::endl;
            exit(1);
          }
          std::cout << std::endl;

          //decryption
          std::array<mpz_t, d> res_repr;
          for (size_t j = 0; j < d; j++)
          {
            mpz_inits(res_repr[j], nullptr);
          }
          
          //decrypt results
          FV::decrypt_poly(res_repr, sk, pk, c_res);
          poly_crt_res[i].mpz2poly(res_repr);

          auto end_one_mod = std::chrono::system_clock::now();

          std::cout << "Time after one sample/one module (in sec): " << get_time_us(start_one_mod, end_one_mod, 1000000) << std::endl;

          for (size_t j = 0; j < d; j++)
          {
            mpz_clears(res_repr[j], nullptr);
          }

          //reset modulus
          params::plaintextModulus<mpz_class>::reset();
          
        }
        

        //convert back from CRT
        res_f = convert_from_crt(poly_crt_res, cut_point);
        
      }
      
      //evaluation in the plaintext space
      mpf_class res_f_plain;
      if(bPlainMode)
      {
        params::plaintextModulus<mpz_class>::value_mpz=mpz_class(params::poly_p::moduli_product());
        sk_t sk;
        evk_t evk(sk, 32);
        pk_t pk(sk, evk);

        net.set_modulus(mpz_class(params::poly_p::moduli_product()));
        net.set_keys(sk, pk);

        //plain input vector
        std::vector<params::poly_p> poly_crt_sample;
        //approximation input vector
        arma::rowvec approx_sample = arma::rowvec(nInputNodes);

        for(int k = 0; k < nInputNodes; k++)
        {
          //printf("Input node %d\n", k);
          params::poly_p tmpPoly;
          convert_to_crt_one_modulus(tmpPoly, net.get_test_input()(iSample, k), nInputIntPrec, nInputFracPrec);
          approx_sample(k) = naf_to_float(tmpPoly, cut_point_init, params::plaintextModulus<mpz_class>::product_mpz.get_mpz_t()).get_d();
          poly_crt_sample.push_back(tmpPoly);
        }

        //printf("\n");
        params::poly_p poly_res_plain;
        poly_res_plain = net.evaluate_plain(poly_crt_sample);

        output_net_approx(iSample) = net.evaluate_approx(approx_sample);

        std::array<mpz_t, d> res_repr;
        for (size_t j = 0; j < d; j++)
        {
          mpz_inits(res_repr[j], nullptr);
        }
      
        poly_res_plain.poly2mpz(res_repr);

        for(size_t j= 0; j < d; j++)
        {
          //put coefficient in range (-q/2, q/2]
          util::center(res_repr[j], res_repr[j], params::poly_p::moduli_product(), evk.qDivBy2);

          /*
          if(mpz_cmp_d(res_repr[j], 396) > 0 || mpz_cmp_d(res_repr[j], -396) < 0)
          {
            printf("The maximal coefficient is bigger than 396\n");
            goto end_loop;
          }
          */

          if(bWriteCoefs)
          {
            //write coefficients to the file
            char tmp[] = "";
            fout << mpz_get_str(tmp, 10, res_repr[j]) << " ";
          }
        
          //mod t
          mpz_mod(res_repr[j], res_repr[j], params::plaintextModulus<mpz_class>::product_mpz.get_mpz_t());
        }
        if(bWriteCoefs)
          fout << std::endl;

        //print_poly_array(res_repr);

        poly_res_plain.mpz2poly(res_repr);

        for (size_t j = 0; j < d; j++)
        {
          mpz_clears(res_repr[j], nullptr);
        }

        //print_poly(poly_res_plain);

        res_f_plain = naf_to_float(poly_res_plain, cut_point, params::plaintextModulus<mpz_class>::product_mpz.get_mpz_t());
      }
      
      //time end for the whole algorithm
      auto end = std::chrono::system_clock::now();
      total_time += get_time_us(start, end, 1000000);

      printf("w-NAF: %d\n", nWindow);
      std::cout << "Time after one sample (in sec): " << get_time_us(start, end, 1000000) << " avg.: " << total_time/(iSample + 1) << std::endl;
      std::cout << "Remaining time (in sec): " << total_time / (iSample + 1) * (nTestSamples - (iSample + 1)) << std::endl;
      
      std::cout << "Real output: " << output_real(iSample) << std::endl;
      if(bCipherMode)
        std::cout << "Evaluation in the cipher mode: " << res_f.get_d() << std::endl;
      std::cout << "Evaluation in the floating point mode: " << output_net_double(iSample) << std::endl;
      if(bPlainMode)
      {
        std::cout << "Evaluation in the plain(poly) mode: " << res_f_plain.get_d() << std::endl;
        std::cout << "Evaluation in the approximation mode: " << output_net_approx(iSample) << std::endl;
      }

      if(bCipherMode)
        output_net_enc(iSample) = res_f.get_d();
      if(bPlainMode)
        output_net_plain(iSample) = res_f_plain.get_d();
      
      std::cout << (iSample + 1) << "/" << nTestSamples << " samples are done" << std::endl;
      
      if(bCipherMode)
      {
        std::cout << "MSE(Enc): " << mse(output_net_enc.rows(0, iSample), output_real) << std::endl;
        std::cout << "MAPE(Enc): " << mape(output_net_enc.rows(0, iSample), output_real) << std::endl;
      }

      if(bPlainMode)
      {
        std::cout << "MSE(Plain): " << mse(output_net_plain.rows(0, iSample), output_real) << std::endl;
        std::cout << "MAPE(Plain): " << mape(output_net_plain.rows(0, iSample), output_real) << std::endl;

        double cur_error;
        cur_error = fabs(output_net_approx(iSample) - output_net_plain(iSample))/fabs(output_net_approx(iSample));
        if (cur_error > max_error)
        {
          max_error = cur_error;
          max_error_ind = iSample;
        }
        if (cur_error < min_error)
        {
          min_error = cur_error;
          min_error_ind = iSample;
        }
        std::cout << "MAPE(Plain vs approx): " << mape(output_net_approx.rows(0, iSample), output_net_plain.rows(0, iSample)) << std::endl;
        std::cout << "Min diff: " << min_error << " at Sample " << min_error_ind << std::endl;
        std::cout << "Max diff: " << max_error << " at Sample " << max_error_ind << std::endl;
      }
      //to consider only one sample. Delete after use



    }
    if(bWriteCoefs)
      fout.close();

  }

  return 0;
}
