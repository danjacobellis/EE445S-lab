# Lab 7. Vocoder and Guitar Effects

## Aim of the experiment

This experiment demonstrates audio effects commonly applied to harmonic instruments like the guitar.

## Reading assignment

* Lab 7 primer
    
## Lab 7 instructions

### Vocoder in MATLAB

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
    order = 8;
    period = 480*ones(N,1);
    peak = zeros(N,1);
    a = zeros(N,order);
    for i_frame = 1:N
        [r,lg] = xcorr(y(:,i_frame),'biased'); r(lg<0) = [];
        [peak(i_frame),period(i_frame)] = max(r(200:1000));
        a(i_frame,:) = levinson(r,order-1);
    end
    ```
    
### Vocoder in C

### Comb filter

### Distortion

## Lab report contents

Good luck on exam two!