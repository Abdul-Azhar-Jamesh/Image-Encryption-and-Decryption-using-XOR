function encrypted_image = image_encryption(input_image, password, output_dir)
    if nargin < 3
        output_dir = fullfile(pwd, 'output');
    end
    if ~isfolder(output_dir)
        mkdir(output_dir);
    end
    password = char(password);
    % Check if password meets length requirement
    if numel(password) < 8
        error('Password must be at least 8 characters long.');
    end

    % Check for the presence of at least one uppercase letter
    if isempty(regexp(password, '[A-Z]', 'once'))
        error('Password must contain at least one uppercase letter.');
    end

    % Check for the presence of at least one lowercase letter
    if isempty(regexp(password, '[a-z]', 'once'))
        error('Password must contain at least one lowercase letter.');
    end

    % Check for the presence of at least one digit
    if isempty(regexp(password, '[0-9]', 'once'))
        error('Password must contain at least one digit.');
    end

    % Check for the presence of at least one special character
    if isempty(regexp(password, '[!@#$%^&*(),.?":{}|<>]', 'once'))
        error('Password must contain at least one special character.');
    end

    fprintf('Password is strong.\n');

    % Read the input color image
    img = imread(input_image);
    if ~isa(img, 'uint8') || ndims(img) ~= 3 || size(img, 3) ~= 3
        error('Input must be an 8-bit RGB image.');
    end
    [rows, cols, channels] = size(img);

    % Generate a hash-based watermark from the password
    password_hash = dec2hex(sum(double(password) .* (1:numel(password))), 4);
    visible_watermark_text = ['WATERMARK:', password_hash(1:4)]; % First 8 characters for visible watermark
    invisible_watermark_text = password_hash; % Full hash for invisible watermark

    % Define text properties for visible watermark
    position = [cols - 250, rows - 100]; % Bottom-right corner
    font_size = 24;  % Adjust as needed
    text_color = [255, 0, 0]; % Red color for the watermark [R, G, B]

    % Create the visible watermark on the image
    watermarked_image = insertText(img, position, visible_watermark_text, ...
        'FontSize', font_size, 'BoxOpacity', 0, 'TextColor', text_color);

    % Embed an invisible watermark by modifying pixel values subtly
    % Convert invisible watermark text to a binary pattern
    binary_invisible_watermark = dec2bin(invisible_watermark_text, 8) - '0';
    binary_invisible_watermark = binary_invisible_watermark(:);
    watermark_length = numel(binary_invisible_watermark);
    if watermark_length > rows * cols
        error('Image is too small for the watermark.');
    end

    % Embed binary watermark into image pixels (e.g., in the least significant bit of blue channel)
    embedded_image = watermarked_image;
    for i = 1:watermark_length
        row = mod(i - 1, rows) + 1;
        col = mod(floor((i - 1) / rows), cols) + 1;
        % Modify least significant bit in the blue channel
        embedded_image(row, col, 3) = bitset(embedded_image(row, col, 3), 1, binary_invisible_watermark(i));
    end

    % Save the watermarked image with both visible and invisible watermarks
    watermarked_path = fullfile(output_dir, 'watermarked_image.png'); % Use forward slashes
    imwrite(embedded_image, watermarked_path);

    % Convert the password into a numeric seed for encryption
    password_seed = double(sum(double(password) .* (1:numel(password)))); % Ensure password is converted

    % Initialize the encrypted image
    encrypted_image = zeros(rows, cols, channels, 'uint8');

    % For each channel, perform encryption with transformations
    for c = 1:channels
        % Extract the channel
        channel = embedded_image(:, :, c);

        % Generate a channel-specific XOR mask based on the password seed
        rng(password_seed * (c + 1), 'twister');
        xor_mask = uint8(randi([0, 255], rows, cols));

        % Apply XOR to the channel using the XOR mask
        xor_channel = bitxor(channel, xor_mask);

        % Shuffle the rows based on the password-derived seed
        rng(password_seed * (c + 2), 'twister');
        row_order = randperm(rows);
        shuffled_channel = xor_channel(row_order, :);

        % Shuffle the columns based on the password-derived seed
        rng(password_seed * (c + 3), 'twister');
        col_order = randperm(cols);
        encrypted_image(:, :, c) = shuffled_channel(:, col_order);
    end

    % Save the encrypted image
    encrypted_image_path = fullfile(output_dir, 'encrypted_image.png');
    imwrite(encrypted_image, encrypted_image_path);

    % Display the original, watermarked, and encrypted images
    figure;
    imshow(watermarked_image); title('Visible Watermarked Image');
    figure;
    imshow(encrypted_image); title('Encrypted Image with Invisible Watermark');
end

% Function to verify invisible watermark during decryption
function is_authentic = verify_invisible_watermark(image, original_text)
    binary_invisible_watermark = dec2bin(original_text, 8) - '0';
    binary_invisible_watermark = binary_invisible_watermark(:);
    watermark_length = numel(binary_invisible_watermark);

    [rows, cols, ~] = size(image);
    extracted_bits = zeros(watermark_length, 1);

    for i = 1:watermark_length
        row = mod(i - 1, rows) + 1;
        col = mod(floor((i - 1) / rows), cols) + 1;
        % Extract least significant bit in the blue channel
        extracted_bits(i) = bitget(image(row, col, 3), 1);
    end

    % Convert extracted bits to characters and compare with original watermark text
    extracted_text = char(bin2dec(reshape(char(extracted_bits + '0'), 8, []).'))';
    is_authentic = strcmp(extracted_text, original_text);
end
