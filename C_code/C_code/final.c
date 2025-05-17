#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <math.h>
#include <complex.h>

#define N 64  // FFT/IFFT Size
#define K 9  // bit stream size
#define size (1 << K)
#define SNR_dB 15
#define G 16   // Cyclic prefix length
#define C 16
#define OFDM_int 4
#define OFDM_fra 9
#define iteration 9
int random_num0[size];
int random_num1[size];
int random_num2[size];
int output_num0[size];
int output_num1[size];
int output_num2[size];
int output_num0_fixed[size];
int output_num1_fixed[size];
int output_num2_fixed[size];
//float complex QPSK[size/2];
float complex QAM0[size/4];
float complex QAM1[size/4];
float complex QAM2[size/4];
float complex W_FFT[N/2];
float complex W_IFFT[N/2];
float complex W_FFT_fixed[N/2];
float complex fft[3][size/4];
float fft_real[6][size/4];
float fft_real_out[6][size/4];
float complex fft0[size/4];
float complex fft1[size/4];
float complex fft2[size/4];
float complex ifft0[size/4];
float complex ifft1[size/4];
float complex ifft2[size/4];
float complex fft_fixed[3][size/4];
float fft_real_fixed[6][size/4];
float fft_real_out_fixed[6][size/4];
float complex fft0_fixed[size/4];
float complex fft1_fixed[size/4];
float complex fft2_fixed[size/4];
float complex ifft0_fixed[size/4];
float complex ifft1_fixed[size/4];
float complex ifft2_fixed[size/4];
float complex cp0[size/4 + size/16];
float complex cp1[size/4 + size/16];
float complex cp2[size/4 + size/16];
float complex Y[3][size/4 + size/16 + 320];
float complex Y_fixed[3][size/4 + size/16 + 320];
float complex Rx[3][size/4 + size/16 + 320 + 20];
float complex Rx0[size/4 + size/16];
float complex Rx1[size/4 + size/16];
float complex Rx2[size/4 + size/16];
float complex Rx_fixed[3][size/4 + size/16 + 320 + 20];
float complex Rx0_fixed[size/4 + size/16];
float complex Rx1_fixed[size/4 + size/16];
float complex Rx2_fixed[size/4 + size/16];
float complex synchronization_input[size/4 + size/16 + 320 + 20];
float complex input1[size/4 + size/16 + 320 + 20];
float complex input2[size/4 + size/16 + 320 + 20];
float complex preamble[16 * 10 + 32 + 64 * 2];
float complex S[3][size/4 + size/16 + 320];
float complex H[3][3];
float H_real[6][6];
float H_real_fixed[6][6];
float complex HxS[3][size/4 + size/16 + 320];
int error = 0;
float complex short_preamble[16] = {
        -0.11859 + 0.13835*I,
        -0.10009 + 0.10620*I,
        -0.07441 + 0.04404*I,
        0.08332 - 0.04749*I,
        -0.04701 - 0.15311*I,
        0.10240 + 0.00911*I,
        0.09171 - 0.05173*I,
        -0.03336 - 0.22544*I,
        -0.08675 - 0.09663*I,
        -0.01580 + 0.12971*I,
        0.05797 - 0.08449*I,
        0.16867 - 0.01889*I,
        -0.14243 - 0.01781*I,
        -0.01586 - 0.12033*I,
        0.03639 - 0.00353*I,
        -0.04145 + 0.09188*I
};
float complex long_preamble[64] = {
        0.00988 - 0.19764*I, 0.05484 + 0.10125*I, -0.07045 + 0.10409*I, 0.12050 + 0.04687*I,
        -0.11907 + 0.02630*I, 0.11765 - 0.12319*I, 0.20366 + 0.05958*I, -0.02843 + 0.08165*I,
        -0.12098 + 0.09473*I, 0.03069 - 0.09978*I, 0.00943 + 0.09856*I, 0.11461 - 0.05077*I,
        0.20055 - 0.08456*I, -0.01273 - 0.05912*I, -0.09757 - 0.00500*I, 0.08140 - 0.02722*I,
        0.10870 + 0.07906*I, 0.08399 - 0.03119*I, -0.00784 + 0.00670*I, 0.04669 + 0.11349*I,
        0.01870 + 0.07549*I, 0.13924 - 0.03948*I, -0.13613 - 0.00300*I, 0.04561 - 0.02849*I,
        0.01877 - 0.04362*I, -0.06785 + 0.01610*I, -0.06123 + 0.08416*I, -0.17902 + 0.02093*I,
        -0.03366 - 0.02024*I, -0.12298 - 0.02872*I, -0.01677 - 0.13882*I, 0.10864 + 0.12880*I,
        0.08894 - 0.03953*I, -0.05120 + 0.05442*I, 0.05208 - 0.07063*I, 0.07311 - 0.11571*I,
        -0.02647 - 0.06004*I, -0.08495 - 0.09047*I, 0.09771 + 0.00775*I, -0.07320 + 0.17016*I,
        -0.03713 + 0.12268*I, 0.01900 - 0.06757*I, -0.10521 + 0.15212*I, 0.10633 - 0.20737*I,
        -0.03186 + 0.05082*I, 0.12255 + 0.04327*I, 0.12864 + 0.10045*I, -0.12107 - 0.06090*I,
        0.10870 - 0.07906*I, -0.11683 - 0.00687*I, 0.04738 + 0.13631*I, -0.12318 - 0.01392*I,
        0.08731 - 0.08128*I, -0.01204 - 0.09797*I, -0.09776 + 0.04267*I, -0.07647 + 0.05300*I,
        -0.17688 - 0.01567*I, -0.04130 - 0.03582*I, -0.10133 + 0.12114*I, 0.08772 + 0.00603*I,
        0.06261 + 0.01445*I, 0.10002 - 0.00920*I, -0.00272 + 0.09446*I, -0.02513 + 0.04158*I
};
float floatTofixTofloat(float f, int integer_bit, int fraction_bit)
{
    union
    {
        float input;
        uint32_t output;
    } data;

    data.input = f;

    uint32_t sign = (data.output >> 31) & 0x1;
    uint32_t exponent = ((data.output >> 23) & 0xFF) - 127; // 127 is the IEEE 754 bias
    uint32_t mantissa = (data.output & 0x7FFFFF);
    uint32_t mantissa_1;
    uint32_t result_u32;
    if((data.output<<1) == 0)
        result_u32 = 0;
    else
    {
        if((exponent & 0x80000000)!=0)
        {
            exponent = ~exponent + 1;
            if(exponent>fraction_bit)
            {
                result_u32 = 0;
                //printf(" %.2f under\n",f);
            }
            else
            {
                mantissa_1 = (mantissa >> (23 - fraction_bit + exponent) << (23 - fraction_bit + exponent));
                result_u32 = ((data.output & 0xFF800000) | mantissa_1);
            }
        }
        else
        {
            if(exponent>(integer_bit-2))
            {
                result_u32 = 0;
                printf("%f over\n",f);
            }
            else
            {
                mantissa_1 = (mantissa >> (23 - fraction_bit - exponent) << (23 - fraction_bit - exponent));
                result_u32 = ((data.output & 0xFF800000) | mantissa_1);
            }
        }
    }
    union
    {
        uint32_t input1;
        float output1;
    } data1;

    data1.input1 = result_u32;
    return data1.output1;
}
void complex_matrix_multiply(complex float input1[3][3], complex float input2[3][size/4 + size/16 + 320], complex float output[3][size/4 + size/16 + 320]) {
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < (size/4 + size/16 + 320); j++) {
            output[i][j] = 0.0 + 0.0 * I;
            for (int k = 0; k < 3; k++) {
                output[i][j] += input1[i][k] * input2[k][j];
            }
        }
    }
}
void matrix_multiply(float input1[6][6], float input2[6][size/4], float output[6][size/4]) {
    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < (size/4); j++) {
            output[i][j] = 0.0;
            for (int k = 0; k < 6; k++) {
                output[i][j] += input1[i][k] * input2[k][j];
            }
        }
    }
}
void matrix_multiply_fixed(float input1[6][6], float input2[6][size/4], float output[6][size/4]) {
    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < (size/4); j++) {
            output[i][j] = 0.0;
            for (int k = 0; k < 6; k++) {
                float temp = floatTofixTofloat(input1[i][k] * input2[k][j],OFDM_int,OFDM_fra);
                output[i][j] += temp;
                output[i][j] = floatTofixTofloat(output[i][j],OFDM_int,OFDM_fra);
            }
        }
        //printf("Y_hat%.5f\n",output[i][0]);
    }
}
void save_ifft_to_file(const char *filename, complex float *ifft_data, int num_samples) {
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        perror("Failed to open file");
        return;
    }

    // 輸出資料，每筆為複數形式 (real + imag*j)
    for (int i = 0; i < num_samples; i++) {
        fprintf(file, "%0.5f + %0.5fj\n", creal(ifft_data[i]), cimag(ifft_data[i]));
    }

    fclose(file);
    printf("File '%s' has been created with the first %d IFFT samples.\n", filename, num_samples);
}
void save_float_to_file(const char *filename, float *data, int length) {
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        perror("Error opening file");
        return;
    }

    for (int i = 0; i < length; i++) {
        fprintf(file, "%.6f\n", data[i]);
    }

    fclose(file);
}

void save_fixed_to_file(const char *filename, int32_t *data, int length, int total_bits) {
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        perror("Error opening file");
        return;
    }

    for (int i = 0; i < length; i++) {
        for (int bit = total_bits - 1; bit >= 0; bit--) {
            fprintf(file, "%c", (data[i] & (1 << bit)) ? '1' : '0');
        }
        fprintf(file, "\n");
    }

    fclose(file);
}
complex float QAM16_MAP(int symbol) {
    float A = 1/sqrt(10);
    const complex float QAM16_MAP_TABLE[16] = {
        -3+3*I, -3+1*I, -3-3*I, -3-1*I,
        -1+3*I, -1+1*I, -1-3*I, -1-1*I,
         3+3*I,  3+1*I,  3-3*I,  3-1*I,
         1+3*I,  1+1*I,  1-3*I,  1-1*I
    };
    return QAM16_MAP_TABLE[symbol%16] * A;
}
void generate_16QAM_symbols(int random_number[size],float complex QAM[size/4]){
        for (int i = 0; i < size; i += 4) {
        if (random_number[i] == 0 && random_number[i+1] == 0 && random_number[i+2] == 0 && random_number[i+3] == 0)
            QAM[i / 4] = QAM16_MAP(0);
        else if (random_number[i] == 1 && random_number[i+1] == 0 && random_number[i+2] == 0 && random_number[i+3] == 0)
            QAM[i / 4] = QAM16_MAP(1);
        else if (random_number[i] == 0 && random_number[i+1] == 1 && random_number[i+2] == 0 && random_number[i+3] == 0)
            QAM[i / 4] = QAM16_MAP(2);
        else if (random_number[i] == 1 && random_number[i+1] == 1 && random_number[i+2] == 0 && random_number[i+3] == 0)
            QAM[i / 4] = QAM16_MAP(3);
        else if (random_number[i] == 0 && random_number[i+1] == 0 && random_number[i+2] == 1 && random_number[i+3] == 0)
            QAM[i / 4] = QAM16_MAP(4);
        else if (random_number[i] == 1 && random_number[i+1] == 0 && random_number[i+2] == 1 && random_number[i+3] == 0)
            QAM[i / 4] = QAM16_MAP(5);
        else if (random_number[i] == 0 && random_number[i+1] == 1 && random_number[i+2] == 1 && random_number[i+3] == 0)
            QAM[i / 4] = QAM16_MAP(6);
        else if (random_number[i] == 1 && random_number[i+1] == 1 && random_number[i+2] == 1 && random_number[i+3] == 0)
            QAM[i / 4] = QAM16_MAP(7);
        else if (random_number[i] == 0 && random_number[i+1] == 0 && random_number[i+2] == 0 && random_number[i+3] == 1)
            QAM[i / 4] = QAM16_MAP(8);
        else if (random_number[i] == 1 && random_number[i+1] == 0 && random_number[i+2] == 0 && random_number[i+3] == 1)
            QAM[i / 4] = QAM16_MAP(9);
        else if (random_number[i] == 0 && random_number[i+1] == 1 && random_number[i+2] == 0 && random_number[i+3] == 1)
            QAM[i / 4] = QAM16_MAP(10);
        else if (random_number[i] == 1 && random_number[i+1] == 1 && random_number[i+2] == 0 && random_number[i+3] == 1)
            QAM[i / 4] = QAM16_MAP(11);
        else if (random_number[i] == 0 && random_number[i+1] == 0 && random_number[i+2] == 1 && random_number[i+3] == 1)
            QAM[i / 4] = QAM16_MAP(12);
        else if (random_number[i] == 1 && random_number[i+1] == 0 && random_number[i+2] == 1 && random_number[i+3] == 1)
            QAM[i / 4] = QAM16_MAP(13);
        else if (random_number[i] == 0 && random_number[i+1] == 1 && random_number[i+2] == 1 && random_number[i+3] == 1)
            QAM[i / 4] = QAM16_MAP(14);
        else if (random_number[i] == 1 && random_number[i+1] == 1 && random_number[i+2] == 1 && random_number[i+3] == 1)
            QAM[i / 4] = QAM16_MAP(15);
    }
}
/*
void decode_QAM_symbols_fixed(float complex FFT_fixed, int output_num[4], int *max) {
    float min_distance = INFINITY;
    int closest_symbol = 0;

    for(int j = 0; j < 16; j++) {
        float temp_real = floatTofixTofloat(creal(QAM16_MAP(j)),fft_int,fft_fra);
        float temp_imag = floatTofixTofloat(cimag(QAM16_MAP(j)),fft_int,fft_fra);
        float complex temp = temp_real + temp_imag*I;
        float distance = floatTofixTofloat(cabs(FFT_fixed - temp),fft_int,fft_fra);
        if(distance < min_distance) {
            min_distance = distance;
            closest_symbol = j;
        }
        if(abs((int)creal(QAM16_MAP(j)) > *max)){
            *max = abs((int)creal(QAM16_MAP(j)));
        }
        if(abs((int)cimag(QAM16_MAP(j)) > *max)){
            *max = abs((int)cimag(QAM16_MAP(j)));
        }
        if(abs((int)creal(FFT_fixed)) > *max){
            *max = abs((int)creal(fft[i]));
        }
        if(abs((int)cimag(FFT_fixed)) > *max){
            *max = abs((int)cimag(fft[i]));
        }
        if(abs((int)distance) > *max){
            *max = abs((int)distance);
        }
    }
    output_num[3] = (closest_symbol >> 3) & 1;
    output_num[2] = (closest_symbol >> 2) & 1;
    output_num[1] = (closest_symbol >> 1) & 1;
    output_num[0] = closest_symbol & 1;
}
*/
void decode_QAM_symbols(float complex FFT, int output_num[4]) {
    float A = 1/sqrt(10);
    float l = 3.0*A;
    float s = 1.0*A;
    float mid = 2.0*A;
    float out_real;
    float out_imag;
    //printf("FFT:%.5f %.5f\n",crealf(FFT),cimagf(FFT));
    //printf("mid:%.5f\n",mid);
    if (crealf(FFT) <= -mid && cimagf(FFT) >= mid) {
        output_num[0] = 0;
        output_num[1] = 0;
        output_num[2] = 0;
        output_num[3] = 0;
        out_real = -l;
        out_imag = l;
    }
    else if (crealf(FFT) <= -mid && cimagf(FFT) < mid && cimagf(FFT) >= 0) {
        output_num[0] = 1;
        output_num[1] = 0;
        output_num[2] = 0;
        output_num[3] = 0;
        out_real = -l;
        out_imag = s;
    }
    else if (crealf(FFT) <= -mid && cimagf(FFT) < 0 && cimagf(FFT) >= -mid) {
        output_num[0] = 1;
        output_num[1] = 1;
        output_num[2] = 0;
        output_num[3] = 0;
        out_real = -l;
        out_imag = -s;
    }
    else if (crealf(FFT) <= -mid && cimagf(FFT) < -mid) {
        output_num[0] = 0;
        output_num[1] = 1;
        output_num[2] = 0;
        output_num[3] = 0;
        out_real = -l;
        out_imag = -l;
    }
    else if (crealf(FFT) > -mid && crealf(FFT) <= 0 && cimagf(FFT) >= mid) {
        output_num[0] = 0;
        output_num[1] = 0;
        output_num[2] = 1;
        output_num[3] = 0;
        out_real = -s;
        out_imag = l;
    }
    else if (crealf(FFT) > -mid && crealf(FFT) <= 0 && cimagf(FFT) < mid && cimagf(FFT) >= 0) {
        output_num[0] = 1;
        output_num[1] = 0;
        output_num[2] = 1;
        output_num[3] = 0;
        out_real = -s;
        out_imag = s;
    }
    else if (crealf(FFT) > -mid && crealf(FFT) <= 0 && cimagf(FFT) < 0 && cimagf(FFT) >= -mid) {
        output_num[0] = 1;
        output_num[1] = 1;
        output_num[2] = 1;
        output_num[3] = 0;
        out_real = -s;
        out_imag = -s;
    }
    else if (crealf(FFT) > -mid && crealf(FFT) <= 0 && cimagf(FFT) < -mid) {
        output_num[0] = 0;
        output_num[1] = 1;
        output_num[2] = 1;
        output_num[3] = 0;
        out_real = -s;
        out_imag = -l;
        //printf("ya\n");
    }
    else if (crealf(FFT) > 0 && crealf(FFT) <= mid && cimagf(FFT) >= mid) {
        output_num[0] = 0;
        output_num[1] = 0;
        output_num[2] = 1;
        output_num[3] = 1;
        out_real = s;
        out_imag = l;
    }
    else if (crealf(FFT) > 0 && crealf(FFT) <= mid && cimagf(FFT) < mid && cimagf(FFT) >= 0) {
        output_num[0] = 1;
        output_num[1] = 0;
        output_num[2] = 1;
        output_num[3] = 1;
        out_real = s;
        out_imag = s;
    }
    else if (crealf(FFT) > 0 && crealf(FFT) <= mid && cimagf(FFT) < 0 && cimagf(FFT) >= -mid) {
        output_num[0] = 1;
        output_num[1] = 1;
        output_num[2] = 1;
        output_num[3] = 1;
        out_real = s;
        out_imag = -l;
    }
    else if (crealf(FFT) > 0 && crealf(FFT) <= mid && cimagf(FFT) < -mid) {
        output_num[0] = 0;
        output_num[1] = 1;
        output_num[2] = 1;
        output_num[3] = 1;
        out_real = s;
        out_imag = -s;
    }
    else if (crealf(FFT) > mid && cimagf(FFT) >= mid) {
        output_num[0] = 0;
        output_num[1] = 0;
        output_num[2] = 0;
        output_num[3] = 1;
        out_real = l;
        out_imag = l;
    }
    else if (crealf(FFT) > mid && cimagf(FFT) < mid && cimagf(FFT) >= 0) {
        output_num[0] = 1;
        output_num[1] = 0;
        output_num[2] = 0;
        output_num[3] = 1;
        out_real = l;
        out_imag = s;
    }
    else if (crealf(FFT) > mid && cimagf(FFT) < 0 && cimagf(FFT) >= -mid) {
        output_num[0] = 1;
        output_num[1] = 1;
        output_num[2] = 0;
        output_num[3] = 1;
        out_real = l;
        out_imag = -s;
    }
    else if (crealf(FFT) > mid && cimagf(FFT) < -mid) {
        output_num[0] = 0;
        output_num[1] = 1;
        output_num[2] = 0;
        output_num[3] = 1;
        out_real = l;
        out_imag = -l;
    }
    else {
        output_num[0] = 0;
        output_num[1] = 0;
        output_num[2] = 0;
        output_num[3] = 0;
        out_real = -l;
        out_imag = l;
    }
    //printf("num:%d %d %d %d\n",output_num[3],output_num[2],output_num[1],output_num[0]);

}

void Build_FFT_Weight(float complex W[N/2]){
    for(int i = 0; i < N/2; i++) {
        W[i] = cexp(I * -2.0 * M_PI * i / N);
    }
}
void Build_IFFT_Weight(float complex W[N/2]){
    for(int i = 0; i < N/2; i++) {
        W[i] = cexp(I * 2.0 * M_PI * i / N);
    }
}
int IBR(int k, int r, int l){
    int temp;
    int result = 0;
    temp = k >> (r-l);
    for(int i=0; i < r; i++){
        result |= ((temp & 1) << (r - i - 1));
        temp >>= 1;
    }
    return result;
}
void Scramble(float complex input[N]){
    float complex Temp_X;
    int check[N];
    int level = log(N) / log(2.0);
    for(int i=0 ;i<N;i++){
        check[i] = 0;
    }
    for(int index=0; index<N; index++){
        if(check[index] == 0){
            int inverse_index = 0;
            Temp_X = input[index];
            for(int i=0; i < level; i++){
                inverse_index |= (((index >>i) & 1) << (level - i - 1));
            }
            input[index] = input[inverse_index];
            input[inverse_index] = Temp_X;
            check[index] = 1;
            check[inverse_index] = 1;
        }
    }
}
void FFT(float complex input[N],float complex W[N/2],float complex output[N]){
    float complex Current_X[N],Next_X[N];
    for(int i = 0; i < N; i++) {
        Current_X[i] = input[i];
        //printf("%dfloat: %.5f %.5fi\n",i,creal(Current_X[i]),cimag(Current_X[i]));
    }
    int level = log(N) / log(2.0);
    for(int j=1; j <= level; j++){
        int dual;
        int P;
        dual = N >> j;
        int i = 0;
        int end = 0;
        end = i + dual;
        while(end<N){
            for(; i < end; ){
                P = IBR(i,level,j);
                Next_X[i] = Current_X[i] + W[P] * Current_X[i + dual];
                Next_X[i + dual] = Current_X[i] - W[P] * Current_X[i + dual];
                i += 1;
            }
            i += dual;
            end = i + dual;
        }
        for(i=0; i<N; i++){
            Current_X[i] = Next_X[i];
        }

    }
    Scramble(Current_X);
    for(int i=0; i<N; i++){
        output[i] = Current_X[i];
        //printf("float%.6f\n",creal(output[i]));
    }
}
void FFT_fixed(float complex input[N],float complex W[N/2],float complex output[N], int *max){
    float complex Current_X[N],Next_X[N],temp_a;
    for(int i = 0; i < N; i++) {
        Current_X[i] = input[i];
        //printf("%dfixed: %.5f %.5fi\n",i,creal(Current_X[i]),cimag(Current_X[i]));
    }
    int level = log(N) / log(2.0);
    for(int j=1; j <= level; j++){
        int dual;
        int P;
        dual = N >> j;
        int i = 0;
        int end = 0;
        end = i + dual;
        while(end<N){
            for(; i < end; ){
                P = IBR(i,level,j);
                float temp_real = floatTofixTofloat(creal(W[P] * Current_X[i + dual]),OFDM_int,OFDM_fra);
                float temp_imag = floatTofixTofloat(cimag(W[P] * Current_X[i + dual]),OFDM_int,OFDM_fra);
                temp_a = temp_real + temp_imag*I;
                Next_X[i] = Current_X[i] + temp_a;
                Next_X[i + dual] = Current_X[i] - temp_a;
                temp_real = floatTofixTofloat(creal(Next_X[i]),OFDM_int,OFDM_fra);
                temp_imag = floatTofixTofloat(cimag(Next_X[i]),OFDM_int,OFDM_fra);
                Next_X[i] = temp_real + temp_imag*I;
                temp_real = floatTofixTofloat(creal(Next_X[i + dual]),OFDM_int,OFDM_fra);
                temp_imag = floatTofixTofloat(cimag(Next_X[i + dual]),OFDM_int,OFDM_fra);
                Next_X[i + dual] = temp_real + temp_imag*I;
                if(abs((int)creal(Next_X[i])) > *max){
                    *max = abs((int)creal(Next_X[i]));
                }
                if(abs((int)cimag(Next_X[i])) > *max){
                    *max = abs((int)cimag(Next_X[i]));
                }
                if(abs((int)creal(W[P] * Current_X[i + dual])) > *max){
                    *max = abs((int)creal(W[P] * Current_X[i + dual]));
                }
                if(abs((int)cimag(W[P] * Current_X[i + dual])) > *max){
                    *max = abs((int)cimag(W[P] * Current_X[i + dual]));
                }
                if(abs((int)creal(Next_X[i + dual])) > *max){
                    *max = abs((int)creal(Next_X[i + dual]));
                }
                if(abs((int)cimag(Next_X[i + dual])) > *max){
                    *max = abs((int)cimag(Next_X[i + dual]));
                }

                i += 1;
            }
            i += dual;
            end = i + dual;
        }
        for(i=0; i<N; i++){
            Current_X[i] = Next_X[i];
        }

    }
    Scramble(Current_X);
    for(int i=0; i<N; i++){
        output[i] = Current_X[i];
        //printf("fixed%.6f\n",creal(output[i]));
    }
}
void IFFT(float complex input[N],float complex W[N/2],float complex output[N]){
    float complex Current_X[N],Next_X[N],Temp_X;
    for(int i = 0; i < N; i++) {
        Current_X[i] = input[i];
    }
    int level = log(N) / log(2.0);
    for(int j=1; j <= level; j++){
        int dual;
        int P;
        dual = N >> j;
        int i = 0;
        int end = 0;
        end = i + dual;
        while(end<N){
            for(; i < end; ){
                P = IBR(i,level,j);
                Next_X[i] = Current_X[i] + W[P] * Current_X[i + dual];
                Next_X[i + dual] = Current_X[i] - W[P] * Current_X[i + dual];
                i += 1;
            }
            i += dual;
            end = i + dual;
        }
        for(i=0; i<N; i++){
            Current_X[i] = Next_X[i];
        }

    }
    Scramble(Current_X);
    for(int i=0; i<N; i++){
        Current_X[i] /= N;
        output[i] = Current_X[i];
    }
}
void cyclic_prefix(float complex input[N],float complex output[N + N/4]){
    for(int i=0;i<(N + N/4);i++){
        if(i<(N/4))
            output[i] = input[(N/4)*3+i];
        else
            output[i] = input[i-(N/4)];
    }
}
void de_prefix(float complex input[N + N/4],float complex output[N]){
    for(int i=0;i<N;i++){
        output[i] = input[i+(N/4)];
    }
}
float generate_gaussian_noise(float mean, float stddev) {
    float u1;
    do {
        u1 = (float)rand() / RAND_MAX;
    }while(u1 == 0);

    float u2;
    do {
        u2 = (float)rand() / RAND_MAX;
    }while(u2 == 0);
    float z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * M_PI * u2);
    return z0 * stddev + mean;
}
void generate_rayleigh_channel(float complex H[3][3]) {
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            float real_part = generate_gaussian_noise(0, 1) / sqrt(2.0);
            float imag_part = generate_gaussian_noise(0, 1) / sqrt(2.0);
            H[i][j] = real_part + imag_part * I;
        }
    }
}
void AWGN(float complex input_signal[3][size/4 + size/16 + 320], float complex output_signal[3][size/4 + size/16 + 320]) {
    float snr = pow(10, SNR_dB / 10.0);
    float signal_power0 = 0.0;
    float signal_power1 = 0.0;
    float signal_power2 = 0.0;
    for (int i = 0; i < (size/4 + size/16); i++){
        signal_power0 += pow(cabs(input_signal[0][320+i]), 2);
        signal_power1 += pow(cabs(input_signal[1][320+i]), 2);
        signal_power2 += pow(cabs(input_signal[2][320+i]), 2);
    }
    signal_power0 /= size/4 + size/16;
    signal_power1 /= size/4 + size/16;
    signal_power2 /= size/4 + size/16;

    float noise_power0 = signal_power0 / snr;
    float noise_power1 = signal_power1 / snr;
    float noise_power2 = signal_power2 / snr;
    float std_dev0 = sqrt(noise_power0 / 2.0);
    float std_dev1 = sqrt(noise_power1 / 2.0);
    float std_dev2 = sqrt(noise_power2 / 2.0);

    for (int i = 0; i < (size/4 + size/16 + 320); i++) {
        float real_noise0 = generate_gaussian_noise(0, std_dev0);
        float imag_noise0 = generate_gaussian_noise(0, std_dev0);
        float real_noise1 = generate_gaussian_noise(0, std_dev1);
        float imag_noise1 = generate_gaussian_noise(0, std_dev1);
        float real_noise2 = generate_gaussian_noise(0, std_dev2);
        float imag_noise2 = generate_gaussian_noise(0, std_dev2);
        output_signal[0][i] = input_signal[0][i] + (real_noise0 + imag_noise0 * I);
        output_signal[1][i] = input_signal[1][i] + (real_noise1 + imag_noise1 * I);
        output_signal[2][i] = input_signal[2][i] + (real_noise2 + imag_noise2 * I);
    }
}
float auto_correlation_fixed(float complex input_signal[32], int *max) {
    float complex Phi_d = 0;
    float mag_Phi_d = 0;
    float complex temp_a;
    float complex temp_b;
    for (int i = 0; i < 16; i++) {
        float temp_real = floatTofixTofloat(creal(input_signal[i]),OFDM_int,OFDM_fra);
        float temp_imag = floatTofixTofloat(cimag(input_signal[i]),OFDM_int,OFDM_fra);
        temp_a = temp_real + temp_imag*I;
        temp_real = floatTofixTofloat(creal(input_signal[i+16]),OFDM_int,OFDM_fra);
        temp_imag = floatTofixTofloat(cimag(input_signal[i+16]),OFDM_int,OFDM_fra);
        temp_b = temp_real + temp_imag*I;
        float complex Phi_d_temp = conj(temp_a)*temp_b;
        temp_real = floatTofixTofloat(creal(Phi_d_temp),OFDM_int,OFDM_fra);
        temp_imag = floatTofixTofloat(cimag(Phi_d_temp),OFDM_int,OFDM_fra);
        Phi_d_temp = temp_real + temp_imag*I;
        Phi_d += Phi_d_temp;
        temp_real = floatTofixTofloat(creal(Phi_d),OFDM_int,OFDM_fra);
        temp_imag = floatTofixTofloat(cimag(Phi_d),OFDM_int,OFDM_fra);
        Phi_d = temp_real + temp_imag*I;
        if(abs((int)creal(input_signal[i])) > *max){
            *max = abs((int)creal(input_signal[i]));
        }
        if(abs((int)cimag(input_signal[i])) > *max){
            *max = abs((int)cimag(input_signal[i]));
        }
        if(abs((int)creal(input_signal[i+16])) > *max){
            *max = abs((int)creal(input_signal[i+16]));
        }
        if(abs((int)cimag(input_signal[i+16])) > *max){
            *max = abs((int)cimag(input_signal[i+16]));
        }
        if(abs((int)creal(Phi_d)) > *max){
            *max = abs((int)creal(Phi_d));
        }
        if(abs((int)cimag(Phi_d)) > *max){
            *max = abs((int)cimag(Phi_d));
        }

    }
    float temp = cabs(Phi_d);
    mag_Phi_d = floatTofixTofloat(temp,OFDM_int,OFDM_fra);
    //printf("mag_Phi_d:%.4f\n",pow(mag_Phi_d,2));
    return mag_Phi_d ;
}
float cross_correlation_fixed(float complex input_signal[64], int *max) {
    float complex Phi_d = 0;
    float mag_Phi_d = 0;
    float complex temp_a;
    float complex temp_b;
    for (int i = 0; i < 64; i++) {
        float temp_real = floatTofixTofloat(creal(long_preamble[i]),OFDM_int,OFDM_fra);
        float temp_imag = floatTofixTofloat(cimag(long_preamble[i]),OFDM_int,OFDM_fra);
        temp_a = temp_real + temp_imag*I;
        temp_real = floatTofixTofloat(creal(input_signal[i]),OFDM_int,OFDM_fra);
        temp_imag = floatTofixTofloat(cimag(input_signal[i]),OFDM_int,OFDM_fra);
        temp_b = temp_real + temp_imag*I;
        float complex Phi_d_temp = conj(temp_a)*temp_b;
        temp_real = floatTofixTofloat(creal(Phi_d_temp),OFDM_int,OFDM_fra);
        temp_imag = floatTofixTofloat(cimag(Phi_d_temp),OFDM_int,OFDM_fra);
        Phi_d_temp = temp_real + temp_imag*I;
        Phi_d += Phi_d_temp;
        temp_real = floatTofixTofloat(creal(Phi_d),OFDM_int,OFDM_fra);
        temp_imag = floatTofixTofloat(cimag(Phi_d),OFDM_int,OFDM_fra);
        Phi_d = temp_real + temp_imag*I;
        if(abs((int)creal(input_signal[i])) > *max){
            *max = abs((int)creal(input_signal[i]));
        }
        if(abs((int)cimag(input_signal[i])) > *max){
            *max = abs((int)cimag(input_signal[i]));
        }
        if(abs((int)creal(input_signal[i+16])) > *max){
            *max = abs((int)creal(input_signal[i+16]));
        }
        if(abs((int)cimag(input_signal[i+16])) > *max){
            *max = abs((int)cimag(input_signal[i+16]));
        }
        if(abs((int)creal(Phi_d)) > *max){
            *max = abs((int)creal(Phi_d));
        }
        if(abs((int)cimag(Phi_d)) > *max){
            *max = abs((int)cimag(Phi_d));
        }

    }
    float temp = cabs(Phi_d);
    mag_Phi_d = floatTofixTofloat(temp,OFDM_int,OFDM_fra);
    return mag_Phi_d ;
}
float calculate_cordic_gain(int iterations) {
    float k = 1.0;
    for (int i = 0; i < iterations+1; i++) {
        k *= 1.0 / sqrt(1.0 + pow(2, -2 * i));
    }
    return k;
}
void CORDIC_R_mode_fixed(float input_x, float input_y, float input_Degree, float *COS, float *SIN) {
    int i = 0;
    float tempx = input_x;
    float tempy = input_y;
    float tempz = input_Degree;
    //printf("x: %.5f y: %.5f z: %.5f\n",tempx,tempy,tempz);
    while (input_Degree != 0 && i < iteration + 1) {
        if (input_Degree < 0) {
            tempx = input_x + floatTofixTofloat(input_y * pow(2, -i), OFDM_int, OFDM_fra);
            tempy = input_y - floatTofixTofloat(input_x * pow(2, -i), OFDM_int, OFDM_fra);
            tempz = input_Degree + floatTofixTofloat(atan(pow(2, -i)) * 180 / M_PI, 8, OFDM_fra);
        }
        else {
            tempx = floatTofixTofloat(input_x - input_y * pow(2, -i), OFDM_int, OFDM_fra);
            tempy = floatTofixTofloat(input_y + input_x * pow(2, -i), OFDM_int, OFDM_fra);
            tempz = input_Degree - floatTofixTofloat(atan(pow(2, -i)) * 180 / M_PI, 8, OFDM_fra);
        }
        input_x = floatTofixTofloat(tempx, OFDM_int, OFDM_fra);
        input_y = floatTofixTofloat(tempy, OFDM_int, OFDM_fra);
        input_Degree = floatTofixTofloat(tempz, 8, OFDM_fra);
        //printf("%d:x: %.5f y: %.5f z: %.5f\n",i,input_x,input_y,input_Degree);
        i++;
    }
    //printf("%d:x: %.5f y: %.5f z: %.5f\n",i,input_x,input_y,input_Degree);
    float CORDIC_GAIN = calculate_cordic_gain(i-1);
    //CORDIC_GAIN = floatTofixTofloat(CORDIC_GAIN,OFDM_int,OFDM_fra);
    //printf("GAIN : %.5f\n",CORDIC_GAIN);
    *COS = floatTofixTofloat(input_x * CORDIC_GAIN,OFDM_int,OFDM_fra);
    *SIN = floatTofixTofloat(input_y * CORDIC_GAIN,OFDM_int,OFDM_fra);
}
void CORDIC_R_mode(float input_x, float input_y, float input_Degree, float *COS, float *SIN) {
    int i = 0;
    float tempx = input_x;
    float tempy = input_y;
    float tempz = input_Degree;
    //printf("x: %.5f y: %.5f z: %.5f\n",tempx,tempy,tempz);
    while (input_Degree != 0 && i < iteration + 1) {
        if (input_Degree < 0) {
            tempx = input_x + input_y * pow(2, -i);
            tempy = input_y - input_x * pow(2, -i);
            tempz = input_Degree + atan(pow(2, -i)) * 180 / M_PI;
        }
        else {
            tempx = input_x - input_y * pow(2, -i);
            tempy = input_y + input_x * pow(2, -i);
            tempz = input_Degree - atan(pow(2, -i)) * 180 / M_PI;
        }
        input_x = tempx;
        input_y = tempy;
        input_Degree = tempz;
        //printf("%d:x: %.5f y: %.5f z: %.5f\n",i,input_x,input_y,input_Degree);
        i++;
    }
    //printf("%d:x: %.5f y: %.5f z: %.5f\n",i,input_x,input_y,input_Degree);
    float CORDIC_GAIN = calculate_cordic_gain(i-1);
    CORDIC_GAIN = CORDIC_GAIN;
    //printf("GAIN : %.5f\n",CORDIC_GAIN);
    *COS = input_x * CORDIC_GAIN;
    *SIN = input_y * CORDIC_GAIN;
}
void CORDIC_V_mode_fixed(float input_x, float input_y, float input_Degree, float *output_Degree) {
    int i = 0;
    float tempx = input_x;
    float tempy = input_y;
    float tempz = input_Degree;
    //printf("x: %.5f y: %.5f z: %.5f\n",tempx,tempy,tempz);
    while (tempy != 0 && i < iteration + 1) {
        if (input_y < 0) {
            tempx = input_x - floatTofixTofloat(input_y * pow(2, -i), OFDM_int, OFDM_fra);
            tempy = input_y + floatTofixTofloat(input_x * pow(2, -i), OFDM_int, OFDM_fra);
            tempz = input_Degree - floatTofixTofloat(atan(pow(2, -i)) * 180 / M_PI, 8, OFDM_fra);
        }
        else {
            tempx = input_x + floatTofixTofloat(input_y * pow(2, -i), OFDM_int, OFDM_fra);
            tempy = input_y - floatTofixTofloat(input_x * pow(2, -i), OFDM_int, OFDM_fra);
            tempz = input_Degree + floatTofixTofloat(atan(pow(2, -i)) * 180 / M_PI, 8, OFDM_fra);
        }
        input_x = floatTofixTofloat(tempx, OFDM_int, OFDM_fra);
        input_y = floatTofixTofloat(tempy, OFDM_int, OFDM_fra);
        input_Degree = floatTofixTofloat(tempz, 8, OFDM_fra);
        //printf("%d:x: %.5f y: %.5f z: %.5f\n",i,input_x,input_y,input_Degree);
        i++;
    }
    //printf("%d:x: %.5f y: %.5f z: %.5f\n",i,input_x,input_y,input_Degree);
    float CORDIC_GAIN = calculate_cordic_gain(i-1);
    CORDIC_GAIN = floatTofixTofloat(CORDIC_GAIN,OFDM_int,OFDM_fra);
    //printf("GAIN : %.5f\n",CORDIC_GAIN);
    *output_Degree = floatTofixTofloat(input_Degree,8,OFDM_fra);
}
void CORDIC_V_mode(float input_x, float input_y, float input_Degree, float *output_Degree) {
    int i = 0;
    float tempx = input_x;
    float tempy = input_y;
    float tempz = input_Degree;
    //printf("x: %.5f y: %.5f z: %.5f\n",tempx,tempy,tempz);
    while (tempy != 0 && i < iteration + 1) {
        if (input_y < 0) {
            tempx = input_x - input_y * pow(2, -i);
            tempy = input_y + input_x * pow(2, -i);
            tempz = input_Degree - atan(pow(2, -i)) * 180 / M_PI;
        }
        else {
            tempx = input_x + input_y * pow(2, -i);
            tempy = input_y - input_x * pow(2, -i);
            tempz = input_Degree + atan(pow(2, -i)) * 180 / M_PI;
        }
        input_x = tempx;
        input_y = tempy;
        input_Degree = tempz;
        //printf("%d:x: %.5f y: %.5f z: %.5f\n",i,input_x,input_y,input_Degree);
        i++;
    }
    //printf("%d:x: %.5f y: %.5f z: %.5f\n",i,input_x,input_y,input_Degree);
    float CORDIC_GAIN = calculate_cordic_gain(i-1);
    //printf("GAIN : %.5f\n",CORDIC_GAIN);
    *output_Degree = input_Degree;
}
void givens_qr_decomposition(float A[6][6], float Q_T[6][6], float R[6][6]) {

    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
            Q_T[i][j] = (i == j) ? 1.0 : 0.0;
            R[i][j] = A[i][j];
        }
    }

    for (int i = 0; i < 5; i++) {
        for (int j = i + 1; j < 6; j++) {
            float a_ii = R[i][i];
            float a_ji = R[j][i];
            if(a_ji != 0.0){
                float degree = 0;
                float *arctan = &degree;
                *arctan =degree;
                float X = 0, Y = 0;
                float *COS = &X;
                float *SIN = &Y;
                *COS =X;
                *SIN =Y;
                if(a_ii<0){
                    CORDIC_V_mode(-a_ii,-a_ji,0.0,arctan);
                    float tempx,tempy;
                    tempx = R[i][i];
                    tempy = R[j][i];
                    CORDIC_R_mode(R[i][i],R[j][i],-degree,COS,SIN);
                    X = -X;
                    Y = -Y;
                    R[i][i]=X;
                    R[j][i]=0;
                    for (int k = i+1; k < 6; k++) {
                        float tempx,tempy;
                        tempx = R[i][k];
                        tempy = R[j][k];
                        CORDIC_R_mode(R[i][k],R[j][k],-degree,COS,SIN);
                        X = -X;
                        Y = -Y;
                        R[i][k] = X;
                        R[j][k] = Y;
                    }

                    for (int k = 0; k < 6; k++) {
                        tempx = Q_T[i][k];
                        tempy = Q_T[j][k];
                        CORDIC_R_mode(Q_T[i][k],Q_T[j][k],-degree,COS,SIN);
                        X = -X;
                        Y = -Y;
                        Q_T[i][k] = X;
                        Q_T[j][k] = Y;
                        //printf("i:%d j:%d k:%d cos:%.4f sin:%.4f\n",i,j,k,X,Y);
                    }
                }
                else{
                    CORDIC_V_mode(a_ii,a_ji,0.0,arctan);
                    float tempx,tempy;
                    tempx = R[i][i];
                    tempy = R[j][i];
                    CORDIC_R_mode(R[i][i],R[j][i],-degree,COS,SIN);
                    R[i][i]=X;
                    R[j][i]=0;
                    for (int k = i+1; k < 6; k++) {
                        float tempx,tempy;
                        tempx = R[i][k];
                        tempy = R[j][k];
                        CORDIC_R_mode(R[i][k],R[j][k],-degree,COS,SIN);
                        R[i][k] = X;
                        R[j][k] = Y;
                    }

                    for (int k = 0; k < 6; k++) {
                        tempx = Q_T[i][k];
                        tempy = Q_T[j][k];
                        CORDIC_R_mode(Q_T[i][k],Q_T[j][k],-degree,COS,SIN);
                        Q_T[i][k] = X;
                        Q_T[j][k] = Y;
                        //printf("i:%d j:%d k:%d cos:%.4f sin:%.4f\n",i,j,k,X,Y);
                    }
                }
            }
        }
    }
}
void givens_qr_decomposition_fixed(float A[6][6], float Q_T[6][6], float R[6][6]) {

    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
            Q_T[i][j] = (i == j) ? 1.0 : 0.0;
            R[i][j] = A[i][j];
        }
    }

    for (int i = 0; i < 5; i++) {
        for (int j = i + 1; j < 6; j++) {
            float a_ii = R[i][i];
            float a_ji = R[j][i];
            if(a_ji!=0.0){
                float degree = 0;
                float *arctan = &degree;
                *arctan =degree;
                float X = 0, Y = 0;
                float *COS = &X;
                float *SIN = &Y;
                *COS =X;
                *SIN =Y;
                if(a_ii<0){
                    CORDIC_V_mode_fixed(-a_ii,-a_ji,0.0,arctan);
                    float tempx,tempy;
                    tempx = R[i][i];
                    tempy = R[j][i];
                    CORDIC_R_mode_fixed(R[i][i],R[j][i],-degree,COS,SIN);
                    X = -X;
                    Y = -Y;
                    R[i][i]=X;
                    R[j][i]=0;
                    for (int k = i+1; k < 6; k++) {
                        float tempx,tempy;
                        tempx = R[i][k];
                        tempy = R[j][k];
                        CORDIC_R_mode_fixed(R[i][k],R[j][k],-degree,COS,SIN);
                        X = -X;
                        Y = -Y;
                        R[i][k] = X;
                        R[j][k] = Y;
                        /*
                        printf("R_real matrix: degree%.5f\n",-degree);
                        for (int l = 0; l < 6; l++) {
                            for (int m = 0; m < 6; m++) {
                                printf("%6.4f ", R[l][m]);
                            }
                            printf("\n");
                        }
                        */
                    }

                    for (int k = 0; k < 6; k++) {
                        tempx = Q_T[i][k];
                        tempy = Q_T[j][k];
                        CORDIC_R_mode_fixed(Q_T[i][k],Q_T[j][k],-degree,COS,SIN);
                        X = -X;
                        Y = -Y;
                        Q_T[i][k] = X;
                        Q_T[j][k] = Y;
                        //printf("i:%d j:%d k:%d cos:%.4f sin:%.4f\n",i,j,k,X,Y);
                        /*
                        printf("Q_real matrix: degree%.5f\n",-degree);
                        for (int l = 0; l < 6; l++) {
                            for (int m = 0; m < 6; m++) {
                                printf("%6.4f ", Q_T[l][m]);
                            }
                            printf("\n");
                        }
                        */

                    }
                }
                else{
                    CORDIC_V_mode(a_ii,a_ji,0.0,arctan);
                    float tempx,tempy;
                    tempx = R[i][i];
                    tempy = R[j][i];
                    CORDIC_R_mode_fixed(R[i][i],R[j][i],-degree,COS,SIN);
                    R[i][i]=X;
                    R[j][i]=0;
                    for (int k = i+1; k < 6; k++) {
                        float tempx,tempy;
                        tempx = R[i][k];
                        tempy = R[j][k];
                        CORDIC_R_mode_fixed(R[i][k],R[j][k],-degree,COS,SIN);
                        R[i][k] = X;
                        R[j][k] = Y;
                        /*
                        printf("R_real matrix: degree%.5f\n",degree);
                        for (int l = 0; l < 6; l++) {
                            for (int m = 0; m < 6; m++) {
                                printf("%6.4f ", R[l][m]);
                            }
                            printf("\n");
                        }
                        */
                    }

                    for (int k = 0; k < 6; k++) {
                        tempx = Q_T[i][k];
                        tempy = Q_T[j][k];
                        CORDIC_R_mode_fixed(Q_T[i][k],Q_T[j][k],-degree,COS,SIN);
                        Q_T[i][k] = X;
                        Q_T[j][k] = Y;
                        //printf("i:%d j:%d k:%d cos:%.4f sin:%.4f\n",i,j,k,X,Y);
                        /*
                        printf("Q_real matrix: degree%.5f\n",degree);
                        for (int l = 0; l < 6; l++) {
                            for (int m = 0; m < 6; m++) {
                                printf("%6.4f ", Q_T[l][m]);
                            }
                            printf("\n");
                        }
                        */
                    }
                }
            }
        }
    }
}

void detect(float fft_real[6][size/4],float R[6][6],int output_num0[size],int output_num1[size],int output_num2[size]){
    for(int i = 0; i < size/4; i++){
        for (int j = 6 - 1; j >= 0; j--) {
            float sum = 0;
            float complex symbol0;
            float complex symbol1;
            float complex symbol2;
            int num0,num1,num2;
            for (int k = j+1; k < 6; k++) {
                sum += R[j][k] * fft_real[k][i];
            }
            fft_real[j][i] = (fft_real[j][i] - sum) / R[j][j];
            if(j==4){
                symbol2 = fft_real[4][i] + fft_real[5][i]*I;
                decode_QAM_symbols(symbol2,output_num2+i*4);
                num2 = output_num2[i*4] + output_num2[i*4+1]*2 + output_num2[i*4+2]*4 + output_num2[i*4+3]*8;
                fft_real[4][i] = creal(QAM16_MAP(num2));
                fft_real[5][i] = cimag(QAM16_MAP(num2));
            }
            if(j==2){
                symbol1 = fft_real[2][i] + fft_real[3][i]*I;
                decode_QAM_symbols(symbol1,output_num1+i*4);
                num1 = output_num1[i*4] + output_num1[i*4+1]*2 + output_num1[i*4+2]*4 + output_num1[i*4+3]*8;
                fft_real[2][i] = creal(QAM16_MAP(num1));
                fft_real[3][i] = cimag(QAM16_MAP(num1));
            }
            if(j==0){
                symbol0 = fft_real[0][i] + fft_real[1][i]*I;
                decode_QAM_symbols(symbol0,output_num0+i*4);
                num0 = output_num0[i*4] + output_num0[i*4+1]*2 + output_num0[i*4+2]*4 + output_num0[i*4+3]*8;
                fft_real[0][i] = creal(QAM16_MAP(num0));
                fft_real[1][i] = cimag(QAM16_MAP(num0));
            }
        }
    }
}
void detect_fixed(float fft_real[6][size/4],float R[6][6],int output_num0[size],int output_num1[size],int output_num2[size]){
    for(int i = 0; i < size/4; i++){
        for (int j = 6 - 1; j >= 0; j--) {
            float sum = 0;
            float complex symbol0;
            float complex symbol1;
            float complex symbol2;
            int num0,num1,num2;
            for (int k = j+1; k < 6; k++) {
                float temp = floatTofixTofloat(R[j][k] * fft_real[k][i],OFDM_int,OFDM_fra);
                //printf("%d %d %d temp%.5f\n",i,j,k,fft_real[k][i]);
                sum += temp;
                sum = floatTofixTofloat(sum,OFDM_int,OFDM_fra);
            }
            float temp = floatTofixTofloat(fft_real[j][i] - sum,OFDM_int,OFDM_fra);
            //printf("被除數temp%.5f\n",sum);
            temp = floatTofixTofloat(temp / R[j][j],OFDM_int,OFDM_fra);
            //printf("除後temp%.5f\n",temp);
            fft_real[j][i] = temp;
            if(j==4){
                symbol2 = fft_real[4][i] + fft_real[5][i]*I;
                //printf("symbol2:%.4f %.4f\n",fft_real[4][i],fft_real[5][i]);
                decode_QAM_symbols(symbol2,output_num2+i*4);
                num2 = output_num2[i*4] + output_num2[i*4+1]*2 + output_num2[i*4+2]*4 + output_num2[i*4+3]*8;
                //printf("\n");
                //printf("解出channel2:%d\n",num2);
                //printf("\n");
                fft_real[4][i] = floatTofixTofloat(creal(QAM16_MAP(num2)),OFDM_int,OFDM_fra);
                fft_real[5][i] = floatTofixTofloat(cimag(QAM16_MAP(num2)),OFDM_int,OFDM_fra);
            }
            if(j==2){
                symbol1 = fft_real[2][i] + fft_real[3][i]*I;
                //printf("symbol1:%.4f %.4f\n",fft_real[2][i],fft_real[3][i]);
                decode_QAM_symbols(symbol1,output_num1+i*4);
                num1 = output_num1[i*4] + output_num1[i*4+1]*2 + output_num1[i*4+2]*4 + output_num1[i*4+3]*8;
                fft_real[2][i] = floatTofixTofloat(creal(QAM16_MAP(num1)),OFDM_int,OFDM_fra);
                fft_real[3][i] = floatTofixTofloat(cimag(QAM16_MAP(num1)),OFDM_int,OFDM_fra);
                //printf("\n");
                //printf("解出channel1:%d\n",num1);
                //printf("\n");
            }
            if(j==0){
                symbol0 = fft_real[0][i] + fft_real[1][i]*I;
                //printf("symbol0:%.4f %.4f\n",fft_real[0][i],fft_real[1][i]);
                decode_QAM_symbols(symbol0,output_num0+i*4);
                num0 = output_num0[i*4] + output_num0[i*4+1]*2 + output_num0[i*4+2]*4 + output_num0[i*4+3]*8;
                fft_real[0][i] = floatTofixTofloat(creal(QAM16_MAP(num0)),OFDM_int,OFDM_fra);
                fft_real[1][i] = floatTofixTofloat(cimag(QAM16_MAP(num0)),OFDM_int,OFDM_fra);
                //printf("\n");
                //printf("解出channel0:%d\n",num0);
                //printf("\n");
            }
        }
    }
}
int32_t float_to_fixed(float value, int integer_bits, int fraction_bits) {
    int32_t fixed_value = (int32_t)(value * (1 << fraction_bits));
    return fixed_value;
}
void save_synchronization_input_to_files(float complex *synchronization_input, int length, int integer_bits, int fraction_bits) {
    float real_data[length];
    float imag_data[length];
    int32_t real_data_fixed[length];
    int32_t imag_data_fixed[length];
    const int total_bits = integer_bits + fraction_bits; // Including the sign bit

    // Separate real and imaginary parts
    for (int i = 0; i < length; i++) {
        real_data[i] = crealf(synchronization_input[i]);
        imag_data[i] = cimagf(synchronization_input[i]);
        real_data_fixed[i] = float_to_fixed(crealf(synchronization_input[i]), integer_bits, fraction_bits);
        imag_data_fixed[i] = float_to_fixed(cimagf(synchronization_input[i]), integer_bits, fraction_bits);
    }

    // Save real part in decimal and binary
    save_float_to_file("input0_real.txt", real_data, length);
    save_fixed_to_file("input0_real_binary.txt", real_data_fixed, length, total_bits);

    // Save imaginary part in decimal and binary
    save_float_to_file("input0_imag.txt", imag_data, length);
    save_fixed_to_file("input0_imag_binary.txt", imag_data_fixed, length, total_bits);

    printf("Files input0_real.txt, input0_real_binary.txt, input0_imag.txt, and input0_imag_binary.txt have been created.\n");
}
void save_synchronization_input1_to_files(float complex *synchronization_input, int length, int integer_bits, int fraction_bits) {
    float real_data[length];
    float imag_data[length];
    int32_t real_data_fixed[length];
    int32_t imag_data_fixed[length];
    const int total_bits = integer_bits + fraction_bits; // Including the sign bit

    // Separate real and imaginary parts
    for (int i = 0; i < length; i++) {
        real_data[i] = crealf(synchronization_input[i]);
        imag_data[i] = cimagf(synchronization_input[i]);
        real_data_fixed[i] = float_to_fixed(crealf(synchronization_input[i]), integer_bits, fraction_bits);
        imag_data_fixed[i] = float_to_fixed(cimagf(synchronization_input[i]), integer_bits, fraction_bits);
    }

    // Save real part in decimal and binary
    save_float_to_file("input1_real.txt", real_data, length);
    save_fixed_to_file("input1_real_binary.txt", real_data_fixed, length, total_bits);

    // Save imaginary part in decimal and binary
    save_float_to_file("input1_imag.txt", imag_data, length);
    save_fixed_to_file("input1_imag_binary.txt", imag_data_fixed, length, total_bits);

    printf("Files input1_real.txt, input1_real_binary.txt, input1_imag.txt, and input1_imag_binary.txt have been created.\n");
}
void save_synchronization_input2_to_files(float complex *synchronization_input, int length, int integer_bits, int fraction_bits) {
    float real_data[length];
    float imag_data[length];
    int32_t real_data_fixed[length];
    int32_t imag_data_fixed[length];
    const int total_bits = integer_bits + fraction_bits; // Including the sign bit

    // Separate real and imaginary parts
    for (int i = 0; i < length; i++) {
        real_data[i] = crealf(synchronization_input[i]);
        imag_data[i] = cimagf(synchronization_input[i]);
        real_data_fixed[i] = float_to_fixed(crealf(synchronization_input[i]), integer_bits, fraction_bits);
        imag_data_fixed[i] = float_to_fixed(cimagf(synchronization_input[i]), integer_bits, fraction_bits);
    }

    // Save real part in decimal and binary
    save_float_to_file("input2_real.txt", real_data, length);
    save_fixed_to_file("input2_real_binary.txt", real_data_fixed, length, total_bits);

    // Save imaginary part in decimal and binary
    save_float_to_file("input2_imag.txt", imag_data, length);
    save_fixed_to_file("input2_imag_binary.txt", imag_data_fixed, length, total_bits);

    printf("Files input2_real.txt, input2_real_binary.txt, input2_imag.txt, and input2_imag_binary.txt have been created.\n");
}
void save_preamble_to_files(float complex *synchronization_input, int length, int integer_bits, int fraction_bits) {
    float real_data[length];
    float imag_data[length];
    int32_t real_data_fixed[length];
    int32_t imag_data_fixed[length];
    const int total_bits = integer_bits + fraction_bits; // Including the sign bit

    // Separate real and imaginary parts
    for (int i = 0; i < length; i++) {
        real_data[i] = crealf(synchronization_input[i]);
        imag_data[i] = cimagf(synchronization_input[i]);
        real_data_fixed[i] = float_to_fixed(crealf(synchronization_input[i]), integer_bits, fraction_bits);
        imag_data_fixed[i] = float_to_fixed(cimagf(synchronization_input[i]), integer_bits, fraction_bits);
    }

    // Save real part in decimal and binary
    save_float_to_file("long_preamble_real.txt", real_data, length);
    save_fixed_to_file("long_preamble_real_binary.txt", real_data_fixed, length, total_bits);

    // Save imaginary part in decimal and binary
    save_float_to_file("long_preamble_imag.txt", imag_data, length);
    save_fixed_to_file("long_preamble_imag_binary.txt", imag_data_fixed, length, total_bits);

    printf("Files long_preamble_real.txt, long_preamble_real_binary.txt, long_preamble_imag.txt, and long_preamble_imag_binary.txt have been created.\n");
}
void save_H0_to_files(float complex *synchronization_input, int length, int integer_bits, int fraction_bits) {
    float real_data[length];
    float imag_data[length];
    int32_t real_data_fixed[length];
    int32_t imag_data_fixed[length];
    const int total_bits = integer_bits + fraction_bits; // Including the sign bit

    // Separate real and imaginary parts
    for (int i = 0; i < length; i++) {
        real_data[i] = crealf(synchronization_input[i]);
        imag_data[i] = cimagf(synchronization_input[i]);
        real_data_fixed[i] = float_to_fixed(crealf(synchronization_input[i]), integer_bits, fraction_bits);
        imag_data_fixed[i] = float_to_fixed(cimagf(synchronization_input[i]), integer_bits, fraction_bits);
    }

    // Save real part in decimal and binary
    save_float_to_file("H0_real.txt", real_data, length);
    save_fixed_to_file("H0_real_binary.txt", real_data_fixed, length, total_bits);

    // Save imaginary part in decimal and binary
    save_float_to_file("H0_imag.txt", imag_data, length);
    save_fixed_to_file("H0_imag_binary.txt", imag_data_fixed, length, total_bits);

    printf("Files H0_real.txt, H0_real_binary.txt, H0_imag.txt, and H0_imag_binary.txt have been created.\n");
}
void save_H1_to_files(float complex *synchronization_input, int length, int integer_bits, int fraction_bits) {
    float real_data[length];
    float imag_data[length];
    int32_t real_data_fixed[length];
    int32_t imag_data_fixed[length];
    const int total_bits = integer_bits + fraction_bits; // Including the sign bit

    // Separate real and imaginary parts
    for (int i = 0; i < length; i++) {
        real_data[i] = crealf(synchronization_input[i]);
        imag_data[i] = cimagf(synchronization_input[i]);
        real_data_fixed[i] = float_to_fixed(crealf(synchronization_input[i]), integer_bits, fraction_bits);
        imag_data_fixed[i] = float_to_fixed(cimagf(synchronization_input[i]), integer_bits, fraction_bits);
    }

    // Save real part in decimal and binary
    save_float_to_file("H1_real.txt", real_data, length);
    save_fixed_to_file("H1_real_binary.txt", real_data_fixed, length, total_bits);

    // Save imaginary part in decimal and binary
    save_float_to_file("H1_imag.txt", imag_data, length);
    save_fixed_to_file("H1_imag_binary.txt", imag_data_fixed, length, total_bits);

    printf("Files H1_real.txt, H1_real_binary.txt, H1_imag.txt, and H1_imag_binary.txt have been created.\n");
}
void save_H2_to_files(float complex *synchronization_input, int length, int integer_bits, int fraction_bits) {
    float real_data[length];
    float imag_data[length];
    int32_t real_data_fixed[length];
    int32_t imag_data_fixed[length];
    const int total_bits = integer_bits + fraction_bits; // Including the sign bit

    // Separate real and imaginary parts
    for (int i = 0; i < length; i++) {
        real_data[i] = crealf(synchronization_input[i]);
        imag_data[i] = cimagf(synchronization_input[i]);
        real_data_fixed[i] = float_to_fixed(crealf(synchronization_input[i]), integer_bits, fraction_bits);
        imag_data_fixed[i] = float_to_fixed(cimagf(synchronization_input[i]), integer_bits, fraction_bits);
    }

    // Save real part in decimal and binary
    save_float_to_file("H2_real.txt", real_data, length);
    save_fixed_to_file("H2_real_binary.txt", real_data_fixed, length, total_bits);

    // Save imaginary part in decimal and binary
    save_float_to_file("H2_imag.txt", imag_data, length);
    save_fixed_to_file("H2_imag_binary.txt", imag_data_fixed, length, total_bits);

    printf("Files H2_real.txt, H2_real_binary.txt, H2_imag.txt, and H2_imag_binary.txt have been created.\n");
}
void save_gain_to_files(float *synchronization_input, int length, int integer_bits, int fraction_bits) {
    float real_data[length];
    int32_t real_data_fixed[length];
    const int total_bits = integer_bits + fraction_bits; // Including the sign bit

    // Separate real and imaginary parts
    for (int i = 0; i < length; i++) {
        real_data[i] = crealf(synchronization_input[i]);
        real_data_fixed[i] = float_to_fixed(crealf(synchronization_input[i]), integer_bits, fraction_bits);
    }

    // Save real part in decimal and binary
    save_float_to_file("Gain_real.txt", real_data, length);
    save_fixed_to_file("Gain_real_binary.txt", real_data_fixed, length, total_bits);

    printf("Files Gain_real.txt, Gain_real_binary.txt have been created.\n");
}
void save_degree_to_files(float *synchronization_input, int length, int integer_bits, int fraction_bits) {
    float real_data[length];
    int32_t real_data_fixed[length];
    const int total_bits = integer_bits + fraction_bits; // Including the sign bit

    // Separate real and imaginary parts
    for (int i = 0; i < length; i++) {
        real_data[i] = crealf(synchronization_input[i]);
        real_data_fixed[i] = float_to_fixed(crealf(synchronization_input[i]), integer_bits, fraction_bits);
    }

    // Save real part in decimal and binary
    save_float_to_file("Degree_real.txt", real_data, length);
    save_fixed_to_file("Degree_real_binary.txt", real_data_fixed, length, total_bits);

    printf("Files Degree_real.txt, Degree_real_binary.txt, have been created.\n");
}
void save_weight_to_files(float complex *synchronization_input, int length, int integer_bits, int fraction_bits) {
    float real_data[length];
    float imag_data[length];
    int32_t real_data_fixed[length];
    int32_t imag_data_fixed[length];
    const int total_bits = integer_bits + fraction_bits; // Including the sign bit

    // Separate real and imaginary parts
    for (int i = 0; i < length; i++) {
        real_data[i] = crealf(synchronization_input[i]);
        imag_data[i] = cimagf(synchronization_input[i]);
        real_data_fixed[i] = float_to_fixed(crealf(synchronization_input[i]), integer_bits, fraction_bits);
        imag_data_fixed[i] = float_to_fixed(cimagf(synchronization_input[i]), integer_bits, fraction_bits);
    }

    // Save real part in decimal and binary
    save_float_to_file("weight_real.txt", real_data, length);
    save_fixed_to_file("weight_real_binary.txt", real_data_fixed, length, total_bits);

    // Save imaginary part in decimal and binary
    save_float_to_file("weight_imag.txt", imag_data, length);
    save_fixed_to_file("weight_imag_binary.txt", imag_data_fixed, length, total_bits);

    printf("Files weight_real.txt, weight_real_binary.txt, weight_imag.txt, and weight_imag_binary.txt have been created.\n");
}
int main() {
    //srand(time(NULL));
    for(int i=0;i<size;i++){
        //srand(time(NULL));
        random_num0[i] = rand() % 2;
    }
    /*
    FILE *file1 = fopen("random_numbers3.txt", "w");
    for (int i = 0; i < size; i++) {
        fprintf(file1, "%d\n", random_num0[i]);
    }
    fclose(file1);
    */
    FILE *random_file0 = fopen("random_numbers0.txt", "r");
    int number0;
    for (int i = 0; i < size; i++) {
        fscanf(random_file0, "%d", &number0);
        random_num0[i] = number0;
    }
    fclose(random_file0);
    FILE *random_file1 = fopen("random_numbers1.txt", "r");
    int number1;
    for (int i = 0; i < size; i++) {
        fscanf(random_file1, "%d", &number1);
        random_num1[i] = number1;
    }
    fclose(random_file1);
    FILE *random_file2 = fopen("random_numbers2.txt", "r");
    int number2;
    for (int i = 0; i < size; i++) {
        fscanf(random_file2, "%d", &number2);
        random_num2[i] = number2;
    }
    fclose(random_file2);
    generate_16QAM_symbols(random_num0,QAM0);
    generate_16QAM_symbols(random_num1,QAM1);
    generate_16QAM_symbols(random_num2,QAM2);
    printf("QAM complete!!\n");
    Build_IFFT_Weight(W_IFFT);
    Build_FFT_Weight(W_FFT);
    for(int i=0;i<(size/(N*4));i++){
        IFFT(QAM0+i*N,W_IFFT,ifft0+i*N);
        cyclic_prefix(ifft0+i*N,cp0+i*(N + N/4));
        IFFT(QAM1+i*N,W_IFFT,ifft1+i*N);
        cyclic_prefix(ifft1+i*N,cp1+i*(N + N/4));
        IFFT(QAM2+i*N,W_IFFT,ifft2+i*N);
        cyclic_prefix(ifft2+i*N,cp2+i*(N + N/4));
        //printf("original: %.4f %.4fi\n",creal(cp0[i]),cimag(cp0[i]));
        //printf("fixed: %.4f %.4fi\n",creal(awgn_fixed[i]),cimag(awgn_fixed[i]));
    }
    for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 16; j++) {
            preamble[i * 16 + j] = short_preamble[j];
        }
    }
    for (int i = 0; i < 32; i++) {
        preamble[160 + i] = long_preamble[32 + i];
    }
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 64; j++) {
            preamble[192 + i * 64 + j] = long_preamble[j];
        }
    }
    for(int i=0;i<319;i++){
        S[0][i] = preamble[i];
        S[1][i] = preamble[i];
        S[2][i] = preamble[i];
    }
    for(int i=0;i<(size/4+size/16);i++){
        S[0][320+i] = cp0[i];
        S[1][320+i] = cp1[i];
        S[2][320+i] = cp2[i];
    }
    generate_rayleigh_channel(H);

    complex_matrix_multiply(H,S,HxS);

    AWGN(HxS,Y);

    printf("AWGN complete!!\n");
    for(int i=0;i<size/4 + size/16 + 320;i++){
        float y0_real = floatTofixTofloat(creal(Y[0][i]),OFDM_int,OFDM_fra);
        float y0_imag = floatTofixTofloat(cimag(Y[0][i]),OFDM_int,OFDM_fra);
        float y1_real = floatTofixTofloat(creal(Y[1][i]),OFDM_int,OFDM_fra);
        float y1_imag = floatTofixTofloat(cimag(Y[1][i]),OFDM_int,OFDM_fra);
        float y2_real = floatTofixTofloat(creal(Y[2][i]),OFDM_int,OFDM_fra);
        float y2_imag = floatTofixTofloat(cimag(Y[2][i]),OFDM_int,OFDM_fra);
        Y_fixed[0][i] = y0_real + y0_imag*I;
        Y_fixed[1][i] = y1_real + y1_imag*I;
        Y_fixed[2][i] = y2_real + y2_imag*I;
        Rx[0][i+20] = Y[0][i];
        Rx[1][i+20] = Y[1][i];
        Rx[2][i+20] = Y[2][i];
    }
    //add unwanted_signal to test if auto correlation could work
    float complex unwanted_signal[20];
    for (int i = 0; i < 20; i++) {
        unwanted_signal[i] = Y_fixed[0][i+400];
    }
    for(int i=0;i<20;i++){
        Rx[0][i] = unwanted_signal[i];
        Rx[1][i] = unwanted_signal[i];
        Rx[2][i] = unwanted_signal[i];
        Rx_fixed[0][i] = unwanted_signal[i];
        Rx_fixed[1][i] = unwanted_signal[i];
        Rx_fixed[2][i] = unwanted_signal[i];
    }
    for(int i=0;i<size/4 + size/16 + 320;i++){
        Rx_fixed[0][i+20] = Y_fixed[0][i];
        Rx_fixed[1][i+20] = Y_fixed[1][i];
        Rx_fixed[2][i+20] = Y_fixed[2][i];
    }
    for(int i=0;i<size/4 + size/16 + 320 + 20;i++){
        synchronization_input[i] = Rx_fixed[0][i];
        input1[i] = Rx_fixed[1][i];
        input2[i] = Rx_fixed[2][i];
        //printf("%.5f %.5fi\n",creal(synchronization_input[i]),cimag(synchronization_input[i]));
    }
    int max_integer = 0;
    int *max_int = &max_integer;
    *max_int = max_integer;
    float auto_value;
    float threshhold = 1.1484375;
    int coarse_result;
    for(int i=0;i<32;i++){
        auto_value = auto_correlation_fixed(synchronization_input+i, max_int);
        //printf("%d %.5f\n",i,auto_value);
        if(auto_value>=threshhold){
            coarse_result = i;
            break;
        }
    }

    printf("coarse_result:%d\n",coarse_result);
    printf("max integer:%d\n",max_integer);
    float cross_value;
    float max_cross_value=0;
    int fine_result;
    for(int i=0;i<64;i++){
        cross_value = cross_correlation_fixed(synchronization_input+coarse_result+160+i,max_int);
        //printf("%d %.5f\n",i,cross_value);
        if(cross_value > max_cross_value){
            max_cross_value = cross_value;
            fine_result = coarse_result+160+i+128;
        }
    }
    printf("fine_result:%d\n",fine_result);
    printf("max integer:%d\n",max_integer);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Write File
    save_synchronization_input_to_files(synchronization_input, size/4 + size/16 + 320 + 20, OFDM_int, OFDM_fra);
    save_synchronization_input1_to_files(input1, size/4 + size/16 + 320 + 20, OFDM_int, OFDM_fra);
    save_synchronization_input2_to_files(input2, size/4 + size/16 + 320 + 20, OFDM_int, OFDM_fra);
    save_weight_to_files(W_FFT,32, OFDM_int, OFDM_fra);
    save_preamble_to_files(long_preamble, 64, OFDM_int, OFDM_fra);
    float complex h0[3],h1[3],h2[3];
    for(int i=0;i<3;i++){
        h0[i] = H[0][i];
        h1[i] = H[1][i];
        h2[i] = H[2][i];
    }
    save_H0_to_files(h0, 3, OFDM_int, OFDM_fra);
    save_H1_to_files(h1, 3, OFDM_int, OFDM_fra);
    save_H2_to_files(h2, 3, OFDM_int, OFDM_fra);
    float gain[iteration];
    float degree[iteration];
    for (int i = 0; i < iteration+1; i++) {
        gain[i] = 1.0;
    }
    for (int i = 0; i < iteration+1; i++) {
        for (int j = 0; j < i+1; j++) {
            gain[i] *= 1.0 / sqrt(1.0 + pow(2, -2 * j));
        }
        degree[i] = atan(pow(2, -i)) * 180 / M_PI;
    }
    save_gain_to_files(gain, iteration+1, OFDM_int, OFDM_fra);
    save_degree_to_files(degree, iteration+1, 8, OFDM_fra);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    for(int i=0;i<size/4 + size/16;i++){
        Rx0[i] = Rx[0][i+fine_result];
        Rx1[i] = Rx[1][i+fine_result];
        Rx2[i] = Rx[2][i+fine_result];
        Rx0_fixed[i] = Rx_fixed[0][i+fine_result];
        Rx1_fixed[i] = Rx_fixed[1][i+fine_result];
        Rx2_fixed[i] = Rx_fixed[2][i+fine_result];
    }

    for(int i=0;i<N/2;i++){
        float real = floatTofixTofloat(creal(W_FFT[i]),OFDM_int,OFDM_fra);
        float imag = floatTofixTofloat(cimag(W_FFT[i]),OFDM_int,OFDM_fra);
        W_FFT_fixed[i] = real + imag*I;
    }
    for(int i=0;i<(size/(N*4));i++){
        de_prefix((Rx0+i*(N + N/4)),ifft0+i*N);
        de_prefix((Rx1+i*(N + N/4)),ifft1+i*N);
        de_prefix((Rx2+i*(N + N/4)),ifft2+i*N);
        de_prefix((Rx0_fixed+i*(N + N/4)),ifft0_fixed+i*N);
        de_prefix((Rx1_fixed+i*(N + N/4)),ifft1_fixed+i*N);
        de_prefix((Rx2_fixed+i*(N + N/4)),ifft2_fixed+i*N);
    }
    for(int i=0;i<(size/(N*4));i++){
        FFT(ifft0+i*N,W_FFT,fft0+i*N);
        FFT(ifft1+i*N,W_FFT,fft1+i*N);
        FFT(ifft2+i*N,W_FFT,fft2+i*N);
        FFT_fixed(ifft0_fixed+i*N,W_FFT_fixed,fft0_fixed+i*N,max_int);
        FFT_fixed(ifft1_fixed+i*N,W_FFT_fixed,fft1_fixed+i*N,max_int);
        FFT_fixed(ifft2_fixed+i*N,W_FFT_fixed,fft2_fixed+i*N,max_int);
        //printf("fixed:%.5f %.5f\n",creal(ifft0_fixed[i*N]),cimag(ifft0_fixed[i*N]));
    }

    for(int i=0;i<size/4;i++){
        fft[0][i] = fft0[i];
        fft[1][i] = fft1[i];
        fft[2][i] = fft2[i];
        fft_fixed[0][i] = fft0_fixed[i];
        fft_fixed[1][i] = fft1_fixed[i];
        fft_fixed[2][i] = fft2_fixed[i];
        //printf("%dFFT:%.5f %.5f\n",i,creal(fft0[i]),cimag(fft0[i]));
    }
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            float real = creal(H[i][j]);
            float imag = cimag(H[i][j]);
            H_real[2 * i][2 * j] = real;
            H_real[2 * i][2 * j + 1] = -imag;
            H_real[2 * i + 1][2 * j] = imag;
            H_real[2 * i + 1][2 * j + 1] = real;
            H_real_fixed[2 * i][2 * j] = floatTofixTofloat(real,OFDM_int,OFDM_fra);
            H_real_fixed[2 * i][2 * j + 1] = floatTofixTofloat(-imag,OFDM_int,OFDM_fra);
            H_real_fixed[2 * i + 1][2 * j] = floatTofixTofloat(imag,OFDM_int,OFDM_fra);
            H_real_fixed[2 * i + 1][2 * j + 1] = floatTofixTofloat(real,OFDM_int,OFDM_fra);
        }
    }

    float Q_T[6][6];
    float Q_T_fixed[6][6];
    float R[6][6];
    float R_fixed[6][6];
    printf("H matrix:\n");
    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
            printf("%6.4f ", H_real[i][j]);
        }
        printf("\n");
    }
    givens_qr_decomposition(H_real,Q_T,R);
    givens_qr_decomposition_fixed(H_real_fixed,Q_T_fixed,R_fixed);
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < size/4; j++) {
            float real = creal(fft[i][j]);
            float imag = cimag(fft[i][j]);
            fft_real[2 * i][j] = real;
            fft_real[2 * i+1][j] = imag;
            float real_fixed = creal(fft_fixed[i][j]);
            float imag_fixed = cimag(fft_fixed[i][j]);
            fft_real_fixed[2 * i][j] = floatTofixTofloat(real_fixed,OFDM_int,OFDM_fra);
            fft_real_fixed[2 * i+1][j] = floatTofixTofloat(imag_fixed,OFDM_int,OFDM_fra);
        }
    }
    /*
    printf("Q_real matrix:\n");
    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
            printf("%6.4f ", Q_T[i][j]);
        }
        printf("\n");
    }
    printf("fft matrix:\n");
    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
            printf("%6.4f ", fft_real[i][j]);
        }
        printf("\n");
    }
    printf("R matrix:\n");
    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
            printf("%6.4f ", R[i][j]);
        }
        printf("\n");
    }
    */
    matrix_multiply(Q_T,fft_real,fft_real_out);
    /*
    printf("Q_T matrix:\n");
    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
            printf("%6.4f ", fft_real[i][j]);
        }
        printf("\n");
    }
    */
    matrix_multiply_fixed(Q_T_fixed,fft_real_fixed,fft_real_out_fixed);
    /*
    printf("Q_T_fixed matrix:\n");
    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
            printf("%6.4f ", fft_real_fixed[i][j]);
        }
        printf("\n");
    }
    */
    detect(fft_real_out,R,output_num0,output_num1,output_num2);
    detect_fixed(fft_real_out_fixed,R_fixed,output_num0_fixed,output_num1_fixed,output_num2_fixed);

    int error=0;
    for(int i=0;i<size;i++){
        if(output_num0[i] != random_num0[i]){
            error += 1;
        }
        if(output_num1[i] != random_num1[i]){
            error += 1;
        }
        if(output_num2[i] != random_num2[i]){
            error += 1;
        }
    }
    float BER = (float)error / ((float)size*3);
    printf("Float32:BER:%.8f\n",BER);
    error=0;
    for(int i=0;i<size;i++){
        if(output_num0_fixed[i] != random_num0[i]){
            error += 1;
        }
        if(output_num1_fixed[i] != random_num1[i]){
            error += 1;
        }
        if(output_num2_fixed[i] != random_num2[i]){
            error += 1;
        }
    }
    BER = (float)error / ((float)size*3);
    printf("Fixed:BER:%.8f\n",BER);

    return 0;
}

