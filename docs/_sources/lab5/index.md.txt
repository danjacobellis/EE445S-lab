# Lab 5. Digital Data Transmission by Baseband Pulse Amplitude Modulation (PAM)

## Aim of the experiment

In this experiment, you will learn the basics concepts of digital communications like pulse shaping filters, Nyquist criterion, eye diagram, inter-symbol interference and clock recovery. You will learn digital data transmission using baseband pulse amplitude modulation.

Before you start with the experiment, it is necessary that you have an understanding (at some level) of the following concepts:

* Baseband PAM
* Nyquist criterion
* Inter-symbol Interference (ISI)
* Pulse shaping (raised cosine baseband filtering)
* Eye diagrams
* Interpolation filter bank
* Symbol clock recovery

## Reading assignment

* Digital Signal Processing using Arm Cortex-M based Microcontrollers by Cem Ünsalan, M. Erkin Yücel, H. Deniz Gürhan.
    * Chapter 9, sections 1-6
* Software Receiver Design by C. Richard Johnson, Jr., William A. Sethares and Andrew Klein
    * Sections 2.6-2.16
    * Sections 9.1-9.4
    * Sections 10.1-10.4
    * Sections 11.1-11.6
* Course reader
    * Lecture 7: Interpolation and Pulse Shaping
    * Lecture 13: Digital Pulse Amplitude Modulation (PAM transmitter)
    * Lecture 12: Channel Impairments (communication channel)
    * Lecture 14: Matched Filtering (PAM receiver)
* Common Microcontroller Software Interface Standard (CMSIS) Reference
    * [FIR Interpolating Filter][1]
    
## Lab 5 instructions: week 1

In this exercise, we will transmit the scrambled tree image from the STM board to a PC running a receiver to recover the image.

### Simulation in MATLAB

1. Run the following code which simulates the generation of the transmitted signal. Please download the [file containing the PN sequence from lab four][2], and the [tree image][3]. Ensure that both are accessible on the MATLAB path.

    ```
    f0 = 12000; fs = 48000; sps = 16; fsym = fs/sps;
    pulse_shaping_filter = rcosdesign(0.8,4,sps,'normal');
    carrier = @(n,theta) cos(2*pi*(f0/fs)*n + theta);
    header = str2num(fliplr(dec2bin(2524737185))');
    serialized_data = reshape(imread('tree.png'),[1,128^2])';
    pn16k = readmatrix('pn_16384.txt')'; pn16k = pn16k(:);
    pn16k = fliplr(dec2bin(pn16k))'; pn16k = str2num(pn16k(:));
    scrambled = mod(serialized_data + pn16k,2);
    upsampled_data = upsample([header; scrambled]*2-1,16);
    sequence_of_pulses = conv(upsampled_data,pulse_shaping_filter,'same');
    n = 1:length(sequence_of_pulses);
    modulated = sequence_of_pulses' .* carrier(n,0);
    ```

2. Create an eye diagram using the first 1600 samples of the simulated signal. You can either use the 'eyediagram' function in the communications toolbox or reshape the samples into a matrix and use 'plot'. **Include the eye diagram in your lab report.**

    ```
    eyediagram(sequence_of_pulses(1:1600),16);
    ```

    ```
    figure; plot(reshape(sequence_of_pulses(1:1600),[16,100]));
    ```

### Setting up the transmitter on the STM32 board

1. In lab.c, create an array containing the data stream to transmit. The data stream will have 32 bits of header followed by 16384 bits for the (scrambled) tree image. If we store it as an array of 32-bit words, then we will need an array of length 513.

    ```
    uint32_t data_stream[513] = {0};
    ```
    
    For the header sequence, we will use the output of a maximal-length 5-bit LFSR. Rather than repeat the steps from lab 4 to generate the sequence, you can simply copy the provided sequence which has been computed for you.
    
    ```
    data_stream[0] = 0x967c6ea1;
    ```
    
    The tree data and scrambler are the same as lab four. Populate the remainder of the `data_stream` array with the scrambled tree (`tree[i]^PN[i]`).
    
    ```
    for (i_word = 0; i_word < 512; i_word+=1)
	{
	    data_stream[i_word+1] = tree[i_word]^PN[i_word];
	}
    ```

2. Prepare the pulse-shaping filter according the specifications below. Since the interpolating filterbank requires a filter whose length is a multiple of the upsampling factor (16), remove the last coefficient (which should be equal to zero and has no effect on the filter)

    * Filter type: raised cosine
    * Samples per symbol: 16
    * Sampling Frequency $F_s= 44.1 \text{ kHz}$
    * Rolloff factor: 0.8

    In MATLAB, use the 'rcosdesign' function and copy the coefficients into lab.c

    ```
    pulse_shaping_coeffs = rcosdesign(0.8, 4, 16, 'normal');
    sprintf('%f,',pulse_shaping_coeffs(1:end-1))
    ```

    ```
    float32_t pulse_shaping_coeffs[64] = {<coefficients>};
    ```

3. In lab.c prepare the variables necessary to use the CMSIS library function for the interpolating filter. Take a moment to read the [description of the FIR interpolator function.][1]

    ```
    arm_fir_interpolate_instance_f32 filter_instance; 
    uint8_t upsampling_factor = 16;
    uint16_t num_taps = 64;
    float32_t state[(FRAME_SIZE/4) + 4 - 1] = {0};
    float32_t filter_in[FRAME_SIZE/64] = {0};
    float32_t filter_out[FRAME_SIZE/4] = {0};
    float32_t cos_lut[4] = {1,0,-1,0};
    uint32_t i_lut = 0;
    ```
    
    Also create variables to keep track of our current word and bit position in the data stream (just as you did in lab 4). You can reuse the variables you used for the PN sequence as long as you reset them.
    
    ```
    uint32_t i_word = 0;
    uint32_t i_bit = 0;
    ```
    
4. Initialize the interpolating filter in the lab_init function:

    ```
    arm_fir_interpolate_init_f32 (&filter_instance, upsampling_factor, num_taps, pulse_shaping_coeffs, state, FRAME_SIZE/4);
    ```
    
5. In process_input_buffer, construct the buffer of symbols that we will send to the arm_fir_interpolate_f32 function. 

    ```
    for (uint32_t i_sample = 0; i_sample<FRAME_SIZE/64; i_sample+=1)
    {
        filter_in[i_sample] = ( data_stream[i_word] & (1<<i_bit) ) >> i_bit;
        filter_in[i_sample] = (filter_in[i_sample]*2) - 1;
    
        i_bit += 1;
        if (i_bit == 32)
        {
            i_word += 1;
            i_bit = 0;
            if (i_word > 512){i_word = 0;}
        }
    }
    ```

6. Perform the filtering and copy the result to the output buffer

    ```
    arm_fir_interpolate_f32 (&filter_instance, filter_in, filter_out, FRAME_SIZE/64);
    
    for (uint32_t i_sample = 0; i_sample < FRAME_SIZE/2; i_sample+=1)
    {
         input_buffer[i_sample] = OUTPUT_SCALE_FACTOR*filter_out[i_sample/2]*cos_lut[i_lut];
         i_lut = (i_lut + 1) % 4;
         i_sample+=1;
         input_buffer[i_sample] = 0;
    }
    ```


### Examining the transmission in MATLAB

1. With the transmitter running, record 12 seconds of data using MATLAB and save it to a file.

    ```
    fs = 48000;
    recorder = audiorecorder(fs,16,1);
    recordblocking(recorder, 12);
    scrambled = getaudiodata(recorder)';
    save scrambled scrambled;
    ```
    
2. Remove the scrambler by replacing the line `data_stream[i_word+1] = tree[i_word]^PN[i_word];` with `data_stream[i_word+1] = tree[i_word]`. Repeat the recording, but ensure that you choose a new file name.

    ```
    fs = 48000;
    recorder = audiorecorder(fs,16,1);
    recordblocking(recorder, 12);
    not_scrambled = getaudiodata(recorder)';
    save not_scrambled not_scrambled;
    ```
    
3. Create a spectrogram for both recorded transmissions. **Include both spectrograms in your lab report.**

    ```
    load scrambled;
    figure; spectrogram(scrambled,2^10,0,2^10,48000,'yaxis');

    load not_scrambled;
    figure; spectrogram(not_scrambled,2^10,0,2^10,48000,'yaxis');
    ```

4. Run the [receiver demo][4] in MATLAB using the transmission that was not scrambled. Try to adjust the parameters to recover the tree image. **Include the recovered tree image in your lab report using the best parameters you find.**

## Lab 5 instructions: week 2

In this exercise we will implement two receiver subsystems: carrier recovery and symbol clock recovery.

### Costas loop for carrier recovery

1. In lab.c, create variables necessary for the costas loop. Assume that the lowpass filter in the costas loop is the same pulse shaping filter as before with 64 coefficients.

    ```
    float32_t Ux[64] = {0};
    float32_t Lx[64] = {0};
    float32_t Uy = 0;
    float32_t Ly = 0;
    float32_t wc = 1.5707963267949;
    float32_t theta = 0;
    float32_t mu = 0.01;
    float32_t baseband[FRAME_SIZE/4] = {0};
    uint32_t i_baseband = 0;
    ```

2. Add code to process_left_sample which computes the newest values for the upper and lower branches.

    ```
    float32_t r = input_sample*INPUT_SCALE_FACTOR;
    
    Ux[0] = r*arm_cos_f32(theta);
    Lx[0] = r*arm_sin_f32(theta);
    
    Uy = 0;
    Ly = 0;
    
    for (uint32_t i_sample = 0; i_sample < 64; i_sample +=1)
    {
        Uy += Ux[i_sample]*pulse_shaping_coeffs[i_sample];
        Ly += Lx[i_sample]*pulse_shaping_coeffs[i_sample];
    }
    
    baseband[i_baseband] = Uy;
    i_baseband += 1;
    if (i_baseband > FRAME_SIZE/4){i_baseband = 0;}
    
    for (i_sample = 63; i_sample > 0; i_sample -=1)
    {
        Ux[i_sample] = Ux[i_sample-1];
        Lx[i_sample] = Lx[i_sample-1];
    }
    ```
    
3. Update the estimate of $\theta$.

    ```
    theta += wc - mu*Uy*Ly;
    if (theta > 6.283185){theta -= 6.283185;}
    ```
4. Connect the input jack on the board to a transmitting source (either the matlab simulation via soundsc or a second board running the previous week's lab. Send the output of the costas loop (`Uy`) to the DAC and display the output on the oscilloscope. The pulse shaping filter applies a gain of about 3.005, so you may want to use a smaller scale factor.

    ```
    return OUTPUT_SCALE_FACTOR*Uy*0.3;
    ```

#### Symbol recovery

    ```
    int32_t k = 0;
    uint32_t data[512] = {0}; 
    ```
    
    ```
    if (k == 15)
    {
        k = 0;
        if (Uy>0)
        {
            data[i_word] |= (1<<i_bit);
        }

        i_bit += 1;
        if (i_bit == 32)
        {
            i_word += 1;
            i_bit = 0;
        }

        if (i_word>512)
        {
            display_image(data,128,128);
            display_image(data,128,128);
        }
    }
    else {k +=1;}

## Lab 5 instructions: week 3

#### Timing Recovery

1. In lab.c, create variables necessary to perform symbol clock recovery via output power maximization.

    ```
    int32_t k = 0;
    uint32_t data[512];
    i_word = 0;
    i_bit = 0;
    float32_t costas_output[3] = {0};
    uint32_t i_opt = 0;
    int32_t offset = 0;
    float32_t output_power = 0;
    float32_t max_output_power = 0;
    
    
    ```


    ```
    
    if (k>14)
    {
        i_opt = k-15;
        costas_output[i_opt] = Uy;
        
        output_power = 0;
        int32_t i_circ;
        for (uint32_t i_avg = 0; i_avg < 21; i_avg += 1) 
        {
            i_circ = i_baseband - 16*i_avg;
            if (i_circ<0) {i_circ += FRAME_SIZE/4;}
            output_power += baseband[i_circ] * baseband[i_circ];
        }
        
        if (output_power > max_output_power)
        {
            max_output_power = output_power;
            offset = i_opt - 1;
        }
    }
        
    if (k==17)
    {
        if (costas_output[1+offset]>0)
        {
            data[i_word] |= (1<<i_bit);
        }
        
        i_bit += 1;
        if (i_bit == 32)
        {
            i_word += 1;
            i_bit = 0;
        }
        
        if (i_word>512){
            display_image(data,128,128);
            display_image(data,128,128);
        }
        
        offset = -1;
        max_output_power = 0;
        k = offset;
    }
    else {k += 1;}

    ```

## Lab report contents

Be sure to include everything listed in this section when you submit your lab report. The goal of the report is to help cement what you learned in memory. For sections I, II, and IV, imagine your audience is a student who is your peer but who has not yet completed the lab.

### I. Introduction

Briefly explain the theory and algorithms behind the programs that you wrote. The slides and reading material might help you in writing this section.

### II. Methods

Describe the steps you took to implement the algorithms in your own words.

### III. Results from lab exercise

Present the results you obtain for each task on the assignment sheet. This section should include illustrative oscilloscope screenshots of the DSP algorithms in action. Also include any code that you wrote or modified. Please do not include all of the boilerplate code from the textbook.

#### Week one

* Eye diagram of simulated transmission
* Spectrograms of PAM transmissions
* Recovered tree image
    
### IV. Discussion

In this section, discuss the takeaway from each lab. You can mention any intuition that you developed. Also mention any problems that you faced and how you rectified them.


[1]:https://arm-software.github.io/CMSIS_5/DSP/html/group__FIR__Interpolate.html
[2]:https://danjacobellis.github.io/EE445S-lab/_sources/lab5/pn_16384.md.txt
[3]:https://danjacobellis.github.io/EE445S-lab/_images/tree.png
[4]:https://github.com/danjacobellis/EE445S-lab/raw/main/starter_code/receiver_demo.m
