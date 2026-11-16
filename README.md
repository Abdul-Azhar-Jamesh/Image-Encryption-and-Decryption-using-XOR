# MATLAB Image Scrambling and Watermarking

An educational MATLAB experiment combining password-derived XOR masks, row/column permutations and visible/invisible watermarking. It is an image-processing demonstration and is not a secure encryption system.

## Run

Use MATLAB with image-processing support and Computer Vision Toolbox for `insertText`. From the repository directory:

```matlab
image_encryption('input.png', 'Example9!', 'output');
decoded = image_decryption_with_error_detection('output/encrypted_image.png', 'Example9!', 'output');
```

Use an 8-bit RGB input image. Paths are parameters; omitting the output directory uses `output` under the current working directory. The functions create the directory if needed. Use a disposable demonstration password, not a real account password.

Outputs are `watermarked_image.png`, `encrypted_image.png` and `decrypted_image.png`. The lossless watermarked image records exactly what decryption should recover; it differs from the original because watermarking changes pixels. Reusing an output directory replaces those named files.

## Files

- `image_encryption.m`: readable, callable encryption/watermarking entry point.
- `image_decryption_with_error_detection.m`: readable inverse operation.
- `encrypting.mlx` and `decrypting.mlx`: matching live-script function definitions. Use the `.m` entry points for the commands above.
- `test_round_trip.m`: temporary-directory, pixel-exact round-trip check.
- `Abstract.pdf` and `presentation.pptx`: original project material.

## Check

```matlab
test_round_trip
```

The check compares recovered pixels with the saved watermarked intermediate image and cleans up its own temporary output. It does not establish cryptographic security. Automated execution during maintenance was blocked by the MathWorks licensing service (error 5201); run this check in a licensed MATLAB session before relying on the result.

## Limitations

The password-derived numeric seed and MATLAB `twister` generator are not cryptographic protection. The decryption function name is historical: the function reverses scrambling but does not authenticate the password or detect malicious changes. A password-strength rule does not fix those limitations. Input data, reports and presentations are retained; generated output is ignored by Git.
