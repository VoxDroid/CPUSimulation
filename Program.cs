using System;
using System.Diagnostics;
using System.Threading;

namespace CPUSimulation
{
    class Program
    {
        const int MEMORY_SIZE = 16;
        const int LOAD = 1;
        const int ADD = 2;
        const int STORE = 3;
        const int SUB = 4;
        const int READ = 5;
        const int WRITE = 6;
        const int HALT = 7;

        static void Main(string[] args)
        {
            bool runAgain = true;

            while (runAgain)
            {
                Console.Clear();
                Console.WriteLine("Welcome to the CPU Simulation!");

                // Select Bus Speed
                int busSpeed = GetUserChoice("Select Bus Speed: 1 (Fast), 2 (Medium), 3 (Slow)", 1, 3);
                // Select Memory Type
                int memoryType = GetUserChoice("Select Memory Type: 1 (SRAM), 2 (DRAM)", 1, 2);
                int delayTime = GetDelayTime(busSpeed, memoryType);

                // Initialize memory
                int[] memory = new int[MEMORY_SIZE];
                InitializeMemory(memory);

                // Initialize CPU registers
                int PC = 0; // Program Counter
                int AC = 0; // Accumulator
                bool haltFlag = false;

                Console.WriteLine($"Starting CPU Simulation with Bus Speed: {GetBusSpeedDescription(busSpeed)} and Memory Type: {GetMemoryTypeDescription(memoryType)}");

                // Execution loop
                Stopwatch stopwatch = new Stopwatch();
                stopwatch.Start();

                while (!haltFlag)
                {
                    if (PC >= MEMORY_SIZE)
                    {
                        Console.WriteLine("Program Counter exceeds memory bounds, halting.");
                        break;
                    }

                    // Simulate delay based on bus speed and memory type
                    Thread.Sleep(delayTime);

                    int IR = memory[PC];
                    int opcode = IR / 1000;
                    int address = IR % 1000;

                    switch (opcode)
                    {
                        case LOAD:
                            AC = memory[address];
                            Console.WriteLine($"LOAD from address {address}: AC = {AC}");
                            break;
                        case ADD:
                            AC += memory[address];
                            Console.WriteLine($"ADD from address {address}: AC = {AC}");
                            break;
                        case STORE:
                            memory[address] = AC;
                            Console.WriteLine($"STORE to address {address}: memory[{address}] = {AC}");
                            break;
                        case SUB:
                            AC -= memory[address];
                            Console.WriteLine($"SUB from address {address}: AC = {AC}");
                            break;
                        case READ:
                            Console.Write("Enter input value (0-999): ");
                            if (int.TryParse(Console.ReadLine(), out int inputValue) && inputValue >= 0 && inputValue < 1000)
                            {
                                memory[address] = inputValue;
                                Console.WriteLine($"READ to address {address}: input = {inputValue}");
                            }
                            else
                            {
                                Console.WriteLine("Invalid input! Please enter a value between 0 and 999.");
                            }
                            break;
                        case WRITE:
                            int outputValue = memory[address];
                            Console.WriteLine($"WRITE from address {address}: output = {outputValue}");
                            break;
                        case HALT:
                            haltFlag = true;
                            Console.WriteLine("HALT encountered. Stopping execution.");
                            break;
                        default:
                            Console.WriteLine($"Error: Unknown instruction at PC = {PC}!");
                            haltFlag = true;
                            break;
                    }

                    PC++;
                }

                stopwatch.Stop();

                // Display final state of memory and performance metrics
                DisplayFinalState(memory, AC, PC, stopwatch.ElapsedMilliseconds);

                // Ask user if they want to run again
                runAgain = AskToRunAgain();
            }
        }

        static int GetUserChoice(string prompt, int min, int max)
        {
            int choice;
            do
            {
                Console.WriteLine(prompt);
                if (int.TryParse(Console.ReadLine(), out choice) && choice >= min && choice <= max)
                {
                    return choice;
                }
                Console.WriteLine($"Invalid choice. Please enter a number between {min} and {max}.");
            } while (true);
        }

        static void InitializeMemory(int[] memory)
        {
            memory[0] = 6001; // READ from address 001
            memory[1] = 1001; // LOAD from address 001
            memory[2] = 2002; // ADD value from address 002
            memory[3] = 3003; // STORE to address 003
            memory[4] = 4004; // SUB from address 004
            memory[5] = 5005; // HALT instruction
            // Additional test values can be added here for more complex interactions
        }

        static int GetDelayTime(int busSpeed, int memoryType)
        {
            // Define delay times for different bus speeds and memory types
            int baseDelay = 0;
            switch (busSpeed)
            {
                case 1: baseDelay = 10; break; // Fast
                case 2: baseDelay = 50; break; // Medium
                case 3: baseDelay = 100; break; // Slow
            }

            // Add additional delay for memory types
            if (memoryType == 2) // Assuming DRAM is slower
            {
                baseDelay += 20; // Extra delay for DRAM
            }

            return baseDelay;
        }

        static string GetBusSpeedDescription(int busSpeed)
        {
            switch (busSpeed)
            {
                case 1: return "Fast";
                case 2: return "Medium";
                case 3: return "Slow";
                default: return "Unknown";
            }
        }

        static string GetMemoryTypeDescription(int memoryType)
        {
            switch (memoryType)
            {
                case 1: return "SRAM (Static RAM)";
                case 2: return "DRAM (Dynamic RAM)";
                default: return "Unknown";
            }
        }

        static void DisplayFinalState(int[] memory, int AC, int PC, long executionTime)
        {
            Console.WriteLine("Final Memory State:");
            for (int i = 0; i < MEMORY_SIZE; i++)
            {
                Console.WriteLine($"memory[{i}] = {memory[i]}");
            }
            Console.WriteLine($"Accumulator (AC) = {AC}");
            Console.WriteLine($"Program Counter (PC) = {PC}");
            Console.WriteLine($"Total Execution Time: {executionTime} ms");
        }

        static bool AskToRunAgain()
        {
            Console.WriteLine("Do you want to run the simulation again? (y/n)");
            string response = Console.ReadLine().ToLower();
            return response == "y" || response == "yes";
        }
    }
}
