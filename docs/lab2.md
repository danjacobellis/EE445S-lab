# Lab 2. Generating Cosine and Sine Waves

## Aim of the experiment

The aim of this experiment is to

* explore the design tradeoffs in signal quality vs. runtime complexity in computing amplitude values of sinusoidal signals.

Sinusoidal waveforms will be computed in discrete time, plotted, and played as audio signals.

## Reading assignment

* Digital Signal Processing using Arm Cortex-M based Microcontrollers by Cem Ünsalan, M. Erkin Yücel, H. Deniz Gürhan.
    * Chapter 2, sections 1-5
    * Chapter 3, sections 1-7

* Software Receiver Design by C. Richard Johnson, Jr., William A. Sethares and Andrew Klein
	* Chapter 1
    
* Course reader
    * Lecture 1 slides on [Generating Sinusoidal Signals][1]
    
## Lab 2 instructions: Week 1

In these exercises, we want to generate the continuous signal $x(t) = \sin(2 \pi f_0 t)$ by sending the discrete signal $x[n] = \sin \left( 2 \pi \frac{f_0}{f_s} n\right)$ to the DAC.

### Sinusoidal generation using math library and phase accumulation

The first method we will use to generate a sinusoid is a math library call.

1. Set the sampling rate to $\left(f_s = 16 \text{ kHz} \right)$ in lab.h.

2. Determine the discrete time frequency $\omega_0$ (in radians per sample) corresponding to $f_0 = 1000$ Hz.

3. In lab.c, create a variable corresponding to the current phase. Use the type float32_t.

4. The math library will compute floating point values of the sinusoid in the range $[-1,1]$. Determine an appropriate scaling factor to map this to an appropriate range of the 16-bit DAC. (Hint: an int16_t can take values between −32768 and 32767.)

5. In process_left_sample, replace the current talkthrough behavior with the sinusoidal generation using the math library and phase accumulation:

    * Instead of setting `output_sample = input_sample` , call the math library function:  `output_sample = SCALING_FACTOR * arm_sin_f32(phase)`
    
    * Increment the phase by $\omega_0$
    
6. Using the phase accumulation method, the phase will eventually become too large and cause numerical errors. Add an if statement that prevents the phase from exceeding $2 \pi $.

7. Display the output signal on the oscilloscope and verify the frequency.

**Include the modified process_left_sample function in your lab report and the value of $\omega_0$ you computed.**

### Sinusoidal generation using difference equation

## Lab 2 instructions: Week 2

### Sinusoidal generation using lookup table

## Lab report contents

Be sure to include everything listed in this section when you submit your lab report.

### I. Results from lab exercise

1. Sinusoidal generation using math library and phase accumulation

    * process_left sample function modified for math library method 
    * value of $\omega_0$ used to generate 1 kHz sinusoid$

2. Sinusoidal generation using difference equation

3. Sinusoidal generation using lookup table

### II. Assignment questions

1. Explain (mathematically) what happened when 6 kHz & 7 kHz sine waves were generated for a sample rate of 8 kHz.

2. Why is the scaling factor necessary? What would happen if the scaling factor was left out?

3. When generating a sinusoid with a sampling rate of 8kHz, how many cycles would occur between samples? Assume that the processor is running at 500 MHz. 

4. Repeat the previous question for a sampling rate of 192 kHz.

5. Look at the measurement you obtained for the number of clock cycles required to execute the math library sin function. Compare this number to the answers obtained in the previous two question. What do these numbers tell you about the feasibility of the math library method for generating sinusoids as the sampling rate increases?
    
[1]:http://users.ece.utexas.edu/~bevans/courses/realtime/lectures/01_Sinusoids/lecture1.ppt