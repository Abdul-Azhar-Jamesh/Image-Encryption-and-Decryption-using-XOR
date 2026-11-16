function test_round_trip
    root = fileparts(mfilename('fullpath'));
    addpath(root);
    output_dir = tempname;
    mkdir(output_dir);
    cleanup = onCleanup(@() rmdir(output_dir, 's'));
    previous_visibility = get(groot, 'defaultFigureVisible');
    restore_visibility = onCleanup(@() set(groot, 'defaultFigureVisible', previous_visibility));
    set(groot, 'defaultFigureVisible', 'off');
    close_figures = onCleanup(@() close('all'));
    rng(42);
    original = uint8(randi([0, 255], 256, 256, 3));
    input_path = fullfile(output_dir, 'input.png');
    imwrite(original, input_path);
    image_encryption(input_path, 'Example9!', output_dir);
    decoded = image_decryption_with_error_detection(fullfile(output_dir, 'encrypted_image.png'), 'Example9!', output_dir);
    expected = imread(fullfile(output_dir, 'watermarked_image.png'));
    assert(isequal(decoded, expected), 'Decryption must recover the watermarked image exactly.');
    disp('Round trip passed: recovered the watermarked RGB image.');
end
