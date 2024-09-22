%% CPU, Memory, and I/O System Initialization

% Define memory parameters
MEMORY_SIZE = 16;              % Size of memory
memory = zeros(1, MEMORY_SIZE); % Initialize memory with zeros

% Initialize some values in memory for testing
memory(1) = 6001;  % READ from address 001
memory(2) = 1001;  % LOAD from address 001
memory(3) = 2002;  % ADD value from address 002
memory(4) = 3003;  % STORE to address 003
memory(5) = 4004;  % SUB from address 004
memory(6) = 5005;  % HALT instruction

% Register Initialization
PC = 1;    % Program Counter
AC = 0;    % Accumulator
IR = 0;    % Instruction Register

% I/O Buffers
input_buffer = 0;
output_buffer = 0;

% Opcode Definitions
LOAD  = 1;
ADD   = 2;
STORE = 3;
SUB   = 4;
READ  = 5;
WRITE = 6;
HALT  = 7;

% Define bus speed and other parameters
cpu_clock_speed = 3.5e9;  % CPU clock speed in GHz
memory_speed = 2.1e9;     % Memory speed in Hz
bus_speed = 1.0e9;        % Bus speed in Hz
I_O_speed = 500e6;        % I/O bus speed in Hz

% Control Flag for HALT
halt_flag = false;

% CPU States and Flags
cpu_state = 'IDLE';  % Current state of the CPU
cpu_flag = 0;        % 0 means normal, 1 means error
memory_access_flag = false; % Memory access state

% Performance Metrics
instruction_count = 0; % Count of executed instructions
start_time = tic;      % Start timer for performance measurement

%% Display Initialization Info
fprintf('Initializing Complex CPU Model...\n');
fprintf('CPU Clock Speed: %.2f GHz\n', cpu_clock_speed / 1e9);
fprintf('Memory Speed: %.2f GHz\n', memory_speed / 1e9);
fprintf('Bus Speed: %.2f GHz\n', bus_speed / 1e9);

% Execution Loop
while ~halt_flag
    IR = memory(PC);  % Fetch the instruction from memory
    opcode = floor(IR / 1000);  % Extract opcode
    address = mod(IR, 1000);    % Extract address
    
    cpu_state = 'FETCH';  % Update CPU state to FETCH
    memory_access_flag = true;
    
    % Instruction Validation
    if address < 1 || address > MEMORY_SIZE
        fprintf('Error: Invalid memory address %d at PC = %d!\n', address, PC);
        cpu_flag = 1;  % Set error flag
        halt_flag = true; % Halt execution on error
        break;
    end
    
    switch opcode
        case LOAD
            cpu_state = 'EXECUTE';  % Update CPU state to EXECUTE
            AC = memory(address);    % Load value from memory to accumulator
            fprintf('LOAD from address %d: AC = %d\n', address, AC);
        case ADD
            cpu_state = 'EXECUTE';  % Update CPU state to EXECUTE
            AC = AC + memory(address);  % Add memory value to accumulator
            fprintf('ADD from address %d: AC = %d\n', address, AC);
        case STORE
            cpu_state = 'EXECUTE';  % Update CPU state to EXECUTE
            memory(address) = AC;   % Store accumulator value to memory
            fprintf('STORE to address %d: memory[%d] = %d\n', address, address, AC);
        case SUB
            cpu_state = 'EXECUTE';  % Update CPU state to EXECUTE
            AC = AC - memory(address);  % Subtract memory value from accumulator
            fprintf('SUB from address %d: AC = %d\n', address, AC);
        case READ
            valid_input = false;
            while ~valid_input
                input_buffer = input('Enter input value (0-999): ');  % Get input from user
                if isnumeric(input_buffer) && input_buffer >= 0 && input_buffer < 1000
                    valid_input = true; % Valid input received
                else
                    fprintf('Invalid input! Please enter a value between 0 and 999.\n');
                end
            end
            memory(address) = input_buffer;  % Store input in memory
            fprintf('READ to address %d: input = %d\n', address, input_buffer);
        case WRITE
            output_buffer = memory(address);  % Get value from memory
            fprintf('WRITE from address %d: output = %d\n', address, output_buffer);
        case HALT
            halt_flag = true;  % Stop execution
            fprintf('HALT encountered. Stopping execution.\n');
        otherwise
            fprintf('Error: Unknown instruction at PC = %d!\n', PC);
            cpu_flag = 1;  % Set error flag
    end
    
    % Bus simulation: Data transfer between CPU and memory
    if memory_access_flag
        fprintf('Accessing memory at address %d...\n', address);
        memory_access_time = 1 / bus_speed;  % Simulate bus speed impact
        pause(memory_access_time);  % Simulate memory access delay
        fprintf('Memory access took %.2e seconds.\n', memory_access_time);
        memory_access_flag = false;
    end
    
    % Simulate CPU clock cycle delay
    cpu_cycle_time = 1 / cpu_clock_speed;
    pause(cpu_cycle_time);  % Simulate CPU clock delay
    
    % I/O System Interaction
    if mod(PC, 5) == 0  % For every 5 instructions, simulate I/O access
        fprintf('Simulating I/O Device Access...\n');
        I_O_access_time = 1 / I_O_speed;  % Simulate I/O access time
        pause(I_O_access_time);
        fprintf('I/O access took %.2e seconds.\n', I_O_access_time);
    end
    
    % Increment Program Counter
    PC = PC + 1;
    instruction_count = instruction_count + 1; % Count executed instructions
    
    % Check for out of bounds Program Counter
    if PC > MEMORY_SIZE
        fprintf('Program Counter exceeds memory bounds, halting.\n');
        halt_flag = true;
    end
end

%% Display Final State
disp('Final Memory State:');
disp(memory);
disp(['Accumulator (AC) = ', num2str(AC)]);
disp(['Program Counter (PC) = ', num2str(PC)]);
disp(['CPU Flag = ', num2str(cpu_flag)]);
disp(['Total Instructions Executed: ', num2str(instruction_count)]);
execution_time = toc(start_time); % Calculate total execution time
disp(['Total Execution Time: ', num2str(execution_time), ' seconds']);

%% Performance Logging
% Log performance metrics to a file
log_file = 'cpu_performance_log.txt';
fid = fopen(log_file, 'w');
fprintf(fid, 'Final Memory State:\n');
fprintf(fid, '%d ', memory);
fprintf(fid, '\nAccumulator (AC) = %d\n', AC);
fprintf(fid, 'Program Counter (PC) = %d\n', PC);
fprintf(fid, 'CPU Flag = %d\n', cpu_flag);
fprintf(fid, 'Total Instructions Executed: %d\n', instruction_count);
fprintf(fid, 'Total Execution Time: %.2f seconds\n', execution_time);
fclose(fid);
fprintf('Performance log saved to %s\n', log_file);
