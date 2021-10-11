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
    
## Lab 5 instructions: week 1

In this exercise, we will transmit the scrambled tree image from the STM board to a PC running a receiver to recover the image.

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
    sprintf('%f,',pulse_shaping_coeffs(1:end-1));
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
    
    Also create variables to keep track of our current word and bit position in the data stream (just as you did in lab 4).
    
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
         input_buffer[i_sample] = SCALING_FACTOR*filter_out[i_sample/2]*cos_lut[i_lut];
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

4. Run the [receiver demo][] in MATLAB using the transmission that was not scrambled. Try to adjust the parameters to recover the tree image. **Include the recovered tree image in your lab report using the best parameters you find.**

## Lab 5 instructions: week 2

## Lab 5 instructions: week 3

## Lab report contents

Be sure to include everything listed in this section when you submit your lab report. The goal of the report is to help cement what you learned in memory. For sections I, II, and IV, imagine your audience is a student who is your peer but who has not yet completed the lab.

### I. Introduction

Briefly explain the theory and algorithms behind the programs that you wrote. The slides and reading material might help you in writing this section.

### II. Methods

Describe the steps you took to implement the algorithms in your own words.

### III. Results from lab exercise

Present the results you obtain for each task on the assignment sheet. This section should include illustrative oscilloscope screenshots of the DSP algorithms in action. Also include any code that you wrote or modified. Please do not include all of the boilerplate code from the textbook.

#### Week one

* Spectrograms of PAM transmissions
* Recovered tree image
    
### IV. Discussion

In this section, discuss the takeaway from each lab. You can mention any intuition that you developed. Also mention any problems that you faced and how you rectified them.


[1]:https://arm-software.github.io/CMSIS_5/DSP/html/group__FIR__Interpolate.html

[2]:https://github.com/danjacobellis/EE445S-lab/raw/main/starter_code/receiver_demo.m
