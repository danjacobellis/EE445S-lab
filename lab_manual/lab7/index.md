# Lab 7. Vocoder and Guitar Effects

## Aim of the experiment

This experiment demonstrates audio effects commonly applied to harmonic instruments like the guitar.

## Reading assignment

* Lab 7 primer
    
## Lab 7 instructions

### Vocoder training in MATLAB

In this exercise, we will encode a voice recording into a matrix of IIR filter coefficients.

1. Record or generate a short segment of speech and save it to a file with 48kHz sampling rate.

    ```
    NET.addAssembly('System.Speech');
    speech_synth = System.Speech.Synthesis.SpeechSynthesizer;
    SetOutputToWaveFile(speech_synth,'example.wav');
    Speak(speech_synth,'Put your hands up. This is a filter bank robbery');
    Dispose(speech_synth);
    [y,fs] = audioread('example.wav'); y = resample(y,320,147); fs = 48e3;
    ```
    
2. Break the signal into frames that match the DMA buffer size.

    ```
    L = 2048; N = floor(length(y)/L);
    y(N*L+1:end) = [];
    y = reshape(y,L,N);
    ```

3. Learn the filter corresponding to each frame of data

    ```
    order = 12;
    period = 480*ones(N,1);
    peak = zeros(N,1);
    a = zeros(N,order);
    for i_frame = 1:N
        [r,lg] = xcorr(y(:,i_frame),'biased'); r(lg<0) = [];
        [peak(i_frame),period(i_frame)] = max(r(200:1000));
        a(i_frame,:) = levinson(r,order-1);
    end
    a(isnan(a)) = 0;
    ```
    
4. Format the coefficients for C

    ```
    sprintf( ['{', repmat('%f,',[1,order]) '},\n'], a');
    ```    
    
### Vocoder effect in C

In this exercise, you will apply the learned vocal filter to input data in real time.

1. Initialize a matrix with the filter coefficients computed in MATLAB.

    ```
    float32_t A[<N>][<order>] = {<exported filter coefficients>};
    ```
    
2. Create variables to track the current filter index

    ```
    uint32_t i_sample = 0;
    uint32_t i_filter = 0;
    ```
    
3. Create an array to hold the previous output values

    ```
    float32_t y[12] = {0};
    ```
    

3. In process_left_sample, apply the all-pole IIR filter

    ```
    y[0] = INPUT_SCALE_FACTOR*input_sample;
	for (uint32_t delay = 1; delay < 12; delay+=1)
	{
		y[0] -= y[delay]*A[i_filter][delay];
	}

	output_sample = OUTPUT_SCALE_FACTOR*y[0];

	for (delay = 11; delay > 0; delay-=1)
	{
		y[delay] = y[delay-1];
	}
    ```
    
4. Increment the variables which track the current filter index

    ```
    i_sample += 1;
    if (i_sample == 2048)
    {
        i_filter += 1;
        if (i_filter == 104){i_filter = 0;}
    }
    ```

5. Using a separate phone/laptop, play a recording which contains harmonically rich instrument(s), like a guitar, violin, or synthesizer. Verify that the output shares characteristics of the original speech signal.

### Flanger

In this exercise, you will implement the flanger using the feedforward form of the comb filter.

$$y[n] = x[n] + \alpha x\left[n-K[n]\right]$$

$$K[n] = R \cos(\omega_{\text{flanger}}) + \frac{R}{2}$$

4. Using a separate phone/laptop, play a recording which contains harmonically rich instrument(s), like a guitar, violin, or synthesizer, and listen to the output.

### Distortion

In this exercise, you will implement harmonic distortion using two methods.

1. Add a nonlinearity to the input signal to increase the energy at higher harmonics.
    
    * Option 1 (Overdrive/clipping) : Whenever the absolute value of the signal exceeds some threshold $L$, set the value equal to $\text{sgn}(x[n]) L$
    
    * Option 2 (Bitcrusher/Quantization) : Scale the (fixed point) input signal by $\alpha = 2^-\B$ so that the $B$ least significant bits of information are discarded. then, scale the input by $2^B$ so that the original level is restored.

2. Using a separate phone/laptop, play a recording which contains harmonically rich instrument(s), like a guitar, violin, or synthesizer, and listen to the output.

## Lab report contents

Good luck on exam two!