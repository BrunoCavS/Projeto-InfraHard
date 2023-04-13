
module ControlUnit (
    
    input wire clk, reset,
    
    input wire O, OpCode404,

    input wire [5:0] OpCode, Funct,

    input wire zero, LT, ET, GT, neg,

    output reg [2:0] IorD,
    output reg [1:0] CauseControl,
    output reg MemWR,
    output reg IRWrite,
    output reg [1:0] RegDst,
    output reg [2:0] MemToReg,
    output reg RegWR,
    output reg WriteA,
    output reg WriteB,
    output reg [1:0] AluSrcA,
    output reg [2:0] AluSrcB,
    output reg [2:0] AluOperation,
    output reg AluOutWrite,
    output reg [2:0] PCSource,
    output reg PCWrite,
    output reg EPCWrite,  
    output reg MemDataWrite,
    output reg [1:0] LoadControl,
    output reg [1:0] StoreControl,
    output reg [1:0] ShiftInputControl,
    output reg [1:0] ShiftNControl,
    output reg [2:0] ShiftControl,
    output reg reset_out
    );

    //Variáveis

    reg [5:0] state;
    reg [5:0] counter;

    //Estados

    parameter RESET_State = 6'b111111;
    parameter fetch = 6'b000001;
    parameter decode = 6'b000010;
    parameter op404 = 6'b000011;
    parameter overflow = 6'b000100;

    parameter ADD = 6'b000110;
    parameter AND = 6'b000111;
    parameter JR = 6'b001010;
    parameter SLL = 6'b001101;
    parameter SLLV = 6'b001111;
    parameter SLT = 6'b010000;
    parameter SRA = 6'b010001;
    parameter SRAV = 6'b010010;
    parameter SRL = 6'b010011;
    parameter SUB = 6'b010100;
    parameter BREAK = 6'b010101;
    parameter RTE = 6'b010110;
    parameter ADDI = 6'b011000;
    parameter ADDIU = 6'b011001;
    parameter BEQ = 6'b011010;
    parameter BNE = 6'b011011;
    parameter BLE = 6'b011100;
    parameter BGT = 6'b011101;
    parameter LUI = 6'b100001;
    parameter SLTI = 6'b100101;
    parameter J = 6'b101000;
    parameter JAL = 6'b101001;

    //R Instructions
    parameter opcodeR = 6'b000000;
    
    parameter ADDFunct = 6'b100000;
    parameter ANDFunct = 6'b100100;
    parameter JRFunct = 6'b001000;
    parameter SLLFunct = 6'b000000;
    parameter SLLVFunct = 6'b000100;
    parameter SLTFunct = 6'b101010;
    parameter SRAFunct = 6'b000011;
    parameter SRAVFunct = 6'b000111;
    parameter SRLFunct = 6'b000010;
    parameter SUBFunct = 6'b100010;
    parameter BREAKFunct = 6'b001101;
    parameter RTEFunct = 6'b010011;

    //I Instructions

    parameter ADDIop = 6'b001000;
    parameter ADDIUop = 6'b001001;
    parameter BEQop = 6'b000100;
    parameter BNEop = 6'b000101;
    parameter BLEop = 6'b000110;
    parameter BGTop = 6'b000111;
    parameter SLTIop = 6'b001010;
    parameter LUIop = 6'b001111;

    //J Instructions

    parameter Jop = 6'b000010;
    parameter JALop = 6'b000011;

    //Reset

    initial begin
        reset_out = 1'b1;
    end

    always @(posedge clk) begin

        if(reset == 1'b1)begin
            if(state != RESET_State)begin

                state = RESET_State; //*

                //Setando todos os outputs para 0

                IorD = 3'b000;
                CauseControl = 2'b00;
                MemWR = 1'b0;
                IRWrite = 1'b0;
                //RegDst = 2'b00;
                //MemToReg = 3'b000;
                //RegWR = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                AluSrcA = 2'b00;
                AluSrcB = 3'b000;
                AluOperation = 3'b000;
                AluOutWrite = 1'b0;
                PCSource = 3'b000;
                PCWrite = 1'b0;
                EPCWrite = 1'b0;  
                MemDataWrite = 1'b0;
                LoadControl = 1'b0;
                StoreControl = 2'b00;
                ShiftInputControl = 2'b00;
                ShiftNControl = 2'b00;
                ShiftControl = 3'b000;

                reset_out = 1'b1;


                //Resetando a pilha
                RegDst = 2'b11;
                MemToReg = 3'b111;
                RegWR = 1'b1;

                counter = 6'b000000;
 
            end else begin
                
                state = fetch; //*

                //Setando todos os outputs para 0

                IorD = 3'b000;
                CauseControl = 2'b00;
                MemWR = 1'b0;
                IRWrite = 1'b0;
                //RegDst = 2'b00;
                //MemToReg = 3'b000;
                //RegWR = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                AluSrcA = 2'b00;
                AluSrcB = 3'b000;
                AluOperation = 3'b000;
                AluOutWrite = 1'b0;
                PCSource = 3'b000;
                PCWrite = 1'b0;
                EPCWrite = 1'b0;  
                MemDataWrite = 1'b0;
                LoadControl = 1'b0;
                StoreControl = 2'b00;
                ShiftInputControl = 2'b00;
                ShiftNControl = 2'b00;
                ShiftControl = 3'b000;

                reset_out = 1'b0; //*

                //Resetando a pilha
                RegDst = 2'b11;
                MemToReg = 3'b111;
                RegWR = 1'b1;                

                counter = 6'b000000;

            end

        end else begin
        
            case (state)
                fetch: begin
                    if(counter != 6'b000011)begin

                        state = fetch;

                        CauseControl = 2'b00;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        AluOutWrite = 1'b0;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;
    
                        reset_out = 1'b0;

                        IorD = 3'b000;
                        MemWR = 1'b0;
                        AluSrcA = 2'b00;
                        AluSrcB = 3'b001;
                        AluOperation = 3'b001;
                        PCSource = 3'b010;

                        counter = counter + 1;

                    end else begin

                        IRWrite = 1'b1;
                        PCWrite = 1'b1;
                        PCSource = 3'b010;
                        AluSrcB = 3'b001;
                        AluOperation = 3'b001;
                        counter = 6'b000000;
                        state = decode;

                    end

                end

                decode: begin
                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;
    
                        reset_out = 1'b0;

                        AluSrcA = 2'b00;
                        AluSrcB = 3'b100;
                        AluOperation = 3'b001;
                        RegWR = 1'b0;
                        AluOutWrite = 1'b1;
                        WriteA = 1'b1;
                        WriteB = 1'b1;
                        
                        counter = counter + 1;

                    end else if(counter == 6'b000001) begin

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;

                        reset_out = 1'b0;

                        AluSrcA = 2'b00;
                        AluSrcB = 3'b100;
                        AluOperation = 3'b001;
                        RegWR = 1'b0;
                        AluOutWrite = 1'b1;
                        WriteA = 1'b1;
                        WriteB = 1'b1;                        

                        counter = 6'b000000;

                        case(OpCode)
                            opcodeR: begin
                                case(Funct)
                                    ADDFunct: begin
                                         state = ADD;
                                        end
                                    ANDFunct: begin
                                         state =  AND;
                                        end
                                    JRFunct: begin
                                         state =  JR;
                                        end
                                    SLLFunct: begin
                                         state =  SLL;
                                        end
                                    SLLVFunct: begin
                                         state =  SLLV;
                                        end
                                    SLTFunct: begin
                                         state =  SLT;
                                        end
                                    SRAFunct: begin
                                         state =  SRA;
                                        end
                                    SRAVFunct: begin
                                         state =  SRAV;
                                        end
                                    SRLFunct: begin
                                         state =  SRL;
                                        end
                                    SUBFunct: begin
                                         state =  SUB;
                                        end
                                    BREAKFunct: begin
                                         state =  BREAK;
                                        end
                                    RTEFunct: begin
                                         state =  RTE;
                                        end
                                endcase
                            end
                                
                            ADDIop: begin
                                 state = ADDI;
                                end
                            ADDIUop: begin
                                 state = ADDIU;
                                end
                            BEQop: begin
                                 state = BEQ;
                                end
                            BNEop: begin
                                 state = BNE;
                                end
                            BLEop: begin
                                 state = BLE;
                                end
                            BGTop: begin
                                 state = BGT;
                                end
                            SLTIop: begin
                                 state = SLTI;
                                end
                            LUIop: begin
                                 state = LUI;
                                end

                            Jop: begin
                                 state = J;
                                end
                            JALop: begin
                                 state = JAL;
                                end
                            default: state = op404;
                        endcase

                    end
                end

                ADD: begin
                    
                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;
    

                        reset_out = 1'b0;

                        AluSrcA = 10;
                        AluSrcB = 000;
                        AluOperation = 001;
                        AluOutWrite = 1;

                        
                        counter = counter + 1;
                    
                    end else if(counter == 6'b000001)begin

                        if(O == 1)begin

                            IorD = 3'b000;
                            CauseControl = 2'b00;
                            MemWR = 1'b0;
                            IRWrite = 1'b0;
                            RegDst = 2'b00;
                            MemToReg = 3'b000;
                            RegWR = 1'b0;
                            WriteA = 1'b0;
                            WriteB = 1'b0;
                            AluSrcA = 2'b00;
                            AluSrcB = 3'b000;
                            AluOperation = 3'b000;
                            AluOutWrite = 1'b0;
                            PCSource = 3'b000;
                            PCWrite = 1'b0;
                            EPCWrite = 1'b0;  
                            MemDataWrite = 1'b0;
                            LoadControl = 1'b0;
                            StoreControl = 2'b00;
                            ShiftInputControl = 2'b00;
                            ShiftNControl = 2'b00;
                            ShiftControl = 3'b000;
        

                            reset_out = 1'b0;

                            counter = 6'b000000;
                            state = overflow;
                        end

                        else begin
                            

                            MemToReg = 011;
                            RegDst = 01;
                            RegWR = 1;

                            AluSrcA = 00;
                            AluSrcB = 000;
                            AluOperation = 000;
                            AluOutWrite = 0;

                            counter = counter + 1;
                        end
                    

                    end else if(counter == 6'b000010)begin
                            if(O == 1)begin

                                IorD = 3'b000;
                                CauseControl = 2'b00;
                                MemWR = 1'b0;
                                IRWrite = 1'b0;
                                RegDst = 2'b00;
                                MemToReg = 3'b000;
                                RegWR = 1'b0;
                                WriteA = 1'b0;
                                WriteB = 1'b0;
                                AluSrcA = 2'b00;
                                AluSrcB = 3'b000;
                                AluOperation = 3'b000;
                                AluOutWrite = 1'b0;
                                PCSource = 3'b000;
                                PCWrite = 1'b0;
                                EPCWrite = 1'b0;  
                                MemDataWrite = 1'b0;
                                LoadControl = 1'b0;
                                StoreControl = 2'b00;
                                ShiftInputControl = 2'b00;
                                ShiftNControl = 2'b00;
                                ShiftControl = 3'b000;
            

                                reset_out = 1'b0;
                                counter = 6'b000000;
                                state = overflow;
                        end

                        else begin

                            reset_out = 1'b0;
                            MemToReg = 011;
                            RegDst = 01;
                            RegWR = 1;

                            counter = 6'b000000;
                            state = fetch;
                        end
                    end


                end

                ADDI: begin

                    if(counter == 6'b000000)begin 

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;

                        reset_out = 1'b0;

                        AluSrcA = 10;
                        AluSrcB = 010;
                        AluOperation = 001;
                        AluOutWrite = 1;

                        counter = counter + 1;


                    end else if (counter == 6'b000001) begin

                        if(O == 1) begin

                            IorD = 3'b000;
                            CauseControl = 2'b00;
                            MemWR = 1'b0;
                            IRWrite = 1'b0;
                            RegDst = 2'b00;
                            MemToReg = 3'b000;
                            RegWR = 1'b0;
                            WriteA = 1'b0;
                            WriteB = 1'b0;
                            AluSrcA = 2'b00;
                            AluSrcB = 3'b000;
                            AluOperation = 3'b000;
                            AluOutWrite = 1'b0;
                            PCSource = 3'b000;
                            PCWrite = 1'b0;
                            EPCWrite = 1'b0;  
                            MemDataWrite = 1'b0;
                            LoadControl = 1'b0;
                            StoreControl = 2'b00;
                            ShiftInputControl = 2'b00;
                            ShiftNControl = 2'b00;
                            ShiftControl = 3'b000;      

                            reset_out = 1'b0;
                            counter = 6'b000000;
                            state = overflow;

                        end else begin

                        MemToReg = 3'b011;
                        RegDst = 2'b00;
                        RegWR = 1'b1;

                        AluSrcA = 00;
                        AluSrcB = 000;
                        AluOperation = 000;
                        AluOutWrite = 0;

                        counter = counter + 1;
                        end

                    end else if (counter == 6'b000010) begin

                        if (O == 1) begin

                            IorD = 3'b000;
                            CauseControl = 2'b00;
                            MemWR = 1'b0;
                            IRWrite = 1'b0;
                            RegDst = 2'b00;
                            MemToReg = 3'b000;
                            RegWR = 1'b0;
                            WriteA = 1'b0;
                            WriteB = 1'b0;
                            AluSrcA = 2'b00;
                            AluSrcB = 3'b000;
                            AluOperation = 3'b000;
                            AluOutWrite = 1'b0;
                            PCSource = 3'b000;
                            PCWrite = 1'b0;
                            EPCWrite = 1'b0;  
                            MemDataWrite = 1'b0;
                            LoadControl = 1'b0;
                            StoreControl = 2'b00;
                            ShiftInputControl = 2'b00;
                            ShiftNControl = 2'b00;
                            ShiftControl = 3'b000;          

                            reset_out = 1'b0;
                            counter = 6'b000000;
                            state = overflow;

                        end else begin
                        
                        state = fetch;

                        MemToReg = 3'b011;
                        RegDst = 2'b00;
                        RegWR = 1'b1;

                        counter = 6'b000000;

                        end                        

                    end


                end

                ADDIU: begin
                    
                    if(counter == 6'b000000)begin 

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;

                        reset_out = 1'b1;

                        AluSrcA = 10;
                        AluSrcB = 010;
                        AluOperation = 001;
                        AluOutWrite = 1;

                        counter = counter + 1;


                    end else if (counter == 6'b000001) begin

                        MemToReg = 3'b011;
                        RegDst = 2'b00;
                        RegWR = 1'b1;

                        AluSrcA = 00;
                        AluSrcB = 000;
                        AluOperation = 000;
                        AluOutWrite = 0;

                        counter = counter + 1;

                    end else if (counter == 6'b000010) begin
                        
                        state = fetch;

                        MemToReg = 3'b011;
                        RegDst = 2'b00;
                        RegWR = 1'b1;

                        counter = 6'b000000;                        

                    end               

                end

                AND : begin
                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;

                        reset_out = 1'b0;

                        AluSrcA = 10;
                        AluSrcB = 000;
                        AluOperation = 011;
                        AluOutWrite = 1;

                        
                        counter = counter + 1;
                    
                    end else if(counter == 6'b000001)begin                          

                            MemToReg = 011;
                            RegDst = 01;
                            RegWR = 1;

                            AluSrcA = 00;
                            AluSrcB = 000;
                            AluOperation = 000;
                            AluOutWrite = 0;

                            counter = counter + 1;

                    end else if(counter == 6'b000010)begin
       
                            reset_out = 1'b0;
                            MemToReg = 011;
                            RegDst = 01;
                            RegWR = 1;

                            counter = 6'b000000;
                            state = fetch;
                    end                    

                end

                SUB: begin 

                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;

                        reset_out = 1'b0;

                        AluSrcA = 10;
                        AluSrcB = 000;
                        AluOperation = 010;
                        AluOutWrite = 1;

                        counter = counter + 1;
                    
                    end else if(counter == 6'b000001)begin

                        if(O == 1)begin

                            IorD = 3'b000;
                            CauseControl = 2'b00;
                            MemWR = 1'b0;
                            IRWrite = 1'b0;
                            RegDst = 2'b00;
                            MemToReg = 3'b000;
                            RegWR = 1'b0;
                            WriteA = 1'b0;
                            WriteB = 1'b0;
                            AluSrcA = 2'b00;
                            AluSrcB = 3'b000;
                            AluOperation = 3'b000;
                            AluOutWrite = 1'b0;
                            PCSource = 3'b000;
                            PCWrite = 1'b0;
                            EPCWrite = 1'b0;  
                            MemDataWrite = 1'b0;
                            LoadControl = 1'b0;
                            StoreControl = 2'b00;
                            ShiftInputControl = 2'b00;
                            ShiftNControl = 2'b00;
                            ShiftControl = 3'b000;

                            reset_out = 1'b0;

                            counter = 6'b000000;
                            state = overflow;
                        end

                        else begin
                            
                            MemToReg = 011;
                            RegDst = 01;
                            RegWR = 1;

                            AluSrcA = 00;
                            AluSrcB = 000;
                            AluOperation = 000;
                            AluOutWrite = 0;

                            counter = counter + 1;
                        end
                    

                    end else if(counter == 6'b000010)begin
                        
                        if(O == 1)begin

                            IorD = 3'b000;
                            CauseControl = 2'b00;
                            MemWR = 1'b0;
                            IRWrite = 1'b0;
                            RegDst = 2'b00;
                            MemToReg = 3'b000;
                            RegWR = 1'b0;
                            WriteA = 1'b0;
                            WriteB = 1'b0;
                            AluSrcA = 2'b00;
                            AluSrcB = 3'b000;
                            AluOperation = 3'b000;
                            AluOutWrite = 1'b0;
                            PCSource = 3'b000;
                            PCWrite = 1'b0;
                            EPCWrite = 1'b0;  
                            MemDataWrite = 1'b0;
                            LoadControl = 1'b0;
                            StoreControl = 2'b00;
                            ShiftInputControl = 2'b00;
                            ShiftNControl = 2'b00;
                            ShiftControl = 3'b000;
        

                            reset_out = 1'b0;
                            counter = 6'b000000;
                            state = overflow;
                        end

                        else begin

                            reset_out = 1'b0;
                            MemToReg = 011;
                            RegDst = 01;
                            RegWR = 1;

                            counter = 6'b000000;
                            state = fetch;

                        end
                    end

                end
                
                RESET_State: begin

                    if(counter == 6'b000000)begin

                            state = RESET_State; //*

                            //Setando todos os outputs para 0
                            IorD = 3'b000;
                            CauseControl = 2'b00;
                            MemWR = 1'b0;
                            IRWrite = 1'b0;
                            RegDst = 2'b00;
                            MemToReg = 3'b000;
                            RegWR = 1'b0;
                            WriteA = 1'b0;
                            WriteB = 1'b0;
                            AluSrcA = 2'b00;
                            AluSrcB = 3'b000;
                            AluOperation = 3'b000;
                            AluOutWrite = 1'b0;
                            PCSource = 3'b000;
                            PCWrite = 1'b0;
                            EPCWrite = 1'b0;  
                            MemDataWrite = 1'b0;
                            LoadControl = 1'b0;
                            StoreControl = 2'b00;
                            ShiftInputControl = 2'b00;
                            ShiftNControl = 2'b00;
                            ShiftControl = 3'b000;
        

                            reset_out = 1'b1;

                    end

                end

                overflow : begin

                    if(counter != 5'b00010) begin

                        IRWrite = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;

                        MemToReg = 3'b000;
                        RegDst = 2'b00;
                        RegWR = 1'b0;
                        reset_out = 1'b0;

                        CauseControl = 2'b01;
                        IorD = 3'b001;
                        MemWR = 1'b0;
                        AluSrcA = 2'b00;
                        AluSrcB = 3'b001;
                        AluOperation = 3'b010;

                        counter = counter + 1;

                    end else begin

                        EPCWrite = 1'b1;
                        PCSource = 3'b000;
                        PCWrite = 1'b1;

                        state = fetch;
                        counter = 6'b000000;

                    end


                end

                op404 : begin

                    if(counter == 6'b00000)begin

                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        AluOutWrite = 1'b0;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;

                        reset_out = 1'b0;

                        CauseControl = 2'b00;
                        IorD = 3'b001;
                        MemWR = 1'b0;
                        
                        counter = counter + 1;

                    end else if(counter == 6'b000001) begin

                        CauseControl = 2'b00;
                        IorD = 3'b001;
                        MemWR = 1'b0;

                        AluSrcA = 2'b00;
                        AluSrcB = 3'b001;
                        AluOperation = 3'b010;

                        counter = counter + 1;

                    end else begin

                        EPCWrite = 1'b1;
                        PCSource = 3'b000;
                        PCWrite = 1'b1;

                        state = fetch;
                        counter = 6'b000000;

                    end

                end


                LUI: begin
                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0; 
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        AluOutWrite = 1'b0;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;
                        CauseControl = 2'b00;
                        IorD = 3'b000;
                        MemWR = 1'b0;
                        AluSrcA = 2'b00;
                        AluSrcB = 3'b000;
                        AluOperation = 3'b000;

                        reset_out = 1'b0;

                        ShiftNControl = 2'b01;
                        ShiftControl = 3'b001;
                        ShiftInputControl = 2'b01;
                        

                        counter = counter + 1;
                    
                    end else if (counter == 6'b000001) begin

                        ShiftControl = 3'b010;

                        counter = counter + 1;

                    end else if (counter == 6'b000010) begin

                        MemToReg = 3'b101;
                        RegDst = 2'b00;
                        RegWR = 1'b1;

                        reset_out = 1'b0;

                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;
                        ShiftInputControl = 2'b00;

                        counter = counter + 1;

                    end else if (counter == 6'b000011) begin

                        state = fetch;

                        MemToReg = 3'b101;
                        RegDst = 2'b00;
                        RegWR = 1'b1;

                        counter = 6'b000000;

                    end
                end

                SLL : begin

                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        AluSrcA = 2'b00;
                        AluSrcB = 3'b000;
                        AluOperation = 3'b000;
                        AluOutWrite = 1'b0;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;

                        reset_out = 1'b0;

                        ShiftControl = 3'b001;
                        ShiftInputControl = 2'b10;
                        ShiftNControl = 2'b10;
                        counter = counter + 1;


                    end else if (counter == 6'b000001)begin

                        ShiftControl = 3'b010;

                        counter = counter + 1;

                    end else if (counter == 6'b00010)begin

                        ShiftControl = 3'b000;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;

                        MemToReg = 3'b101;
                        RegDst = 2'b01;
                        RegWR = 1'b1;

                        counter = counter + 1;

                    end else begin

                        MemToReg = 3'b101;
                        RegDst = 2'b01;
                        RegWR = 1'b1;

                        state = fetch;
                        counter = 6'b000000;

                    end


                end

                SLLV: begin

                    if(counter == 6'b000000)begin

                    IorD = 3'b000;
                    CauseControl = 2'b00;
                    MemWR = 1'b0;
                    IRWrite = 1'b0;
                    RegDst = 2'b00;
                    MemToReg = 3'b000;
                    RegWR = 1'b0;
                    WriteA = 1'b0;
                    WriteB = 1'b0;
                    AluSrcA = 2'b00;
                    AluSrcB = 3'b000;
                    AluOperation = 3'b000;
                    AluOutWrite = 1'b0;
                    PCSource = 3'b000;
                    PCWrite = 1'b0;
                    EPCWrite = 1'b0;  
                    MemDataWrite = 1'b0;
                    LoadControl = 1'b0;
                    StoreControl = 2'b00;
                    ShiftInputControl = 2'b00;
                    ShiftNControl = 2'b00;

                    reset_out = 1'b0;

                    ShiftControl = 3'b001;
                    counter = counter + 1;


                    end else if (counter == 6'b000001)begin

                        ShiftControl = 3'b010;
                        ShiftNControl = 2'b00;
                        ShiftInputControl = 2'b00;
                        
                        counter = counter + 1;

                    end else if (counter == 6'b000010)begin

                        ShiftControl = 3'b000;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;

                        MemToReg = 3'b101;
                        RegDst = 2'b01;
                        RegWR = 1'b1;

                        counter = counter + 1;

                    end else begin

                        MemToReg = 3'b101;
                        RegDst = 2'b01;
                        RegWR = 1'b1;

                        state = fetch;
                        counter = 6'b000000;

                    end

                end

                SRA : begin

                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        AluSrcA = 2'b00;
                        AluSrcB = 3'b000;
                        AluOperation = 3'b000;
                        AluOutWrite = 1'b0;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;

                        reset_out = 1'b0;

                        ShiftControl = 3'b001;
                        ShiftInputControl = 2'b10;
                        ShiftNControl = 2'b10;
                        counter = counter + 1;


                    end else if (counter == 6'b000001)begin

                        ShiftControl = 3'b100;

                        counter = counter + 1;

                    end else if (counter == 6'b000010)begin

                        ShiftControl = 3'b000;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;

                        MemToReg = 3'b101;
                        RegDst = 2'b01;
                        RegWR = 1'b1;

                        counter = counter + 1;

                    end else begin

                        MemToReg = 3'b101;
                        RegDst = 2'b01;
                        RegWR = 1'b1;

                        state = fetch;
                        counter = 6'b000000;

                    end

                end

                SRAV: begin

                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        AluSrcA = 2'b00;
                        AluSrcB = 3'b000;
                        AluOperation = 3'b000;
                        AluOutWrite = 1'b0;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;

                        reset_out = 1'b0;

                        ShiftControl = 3'b001;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;
                        counter = counter + 1;


                    end else if (counter == 6'b000001)begin

                        ShiftControl = 3'b100;

                        counter = counter + 1;

                    end else if (counter == 6'b000010)begin

                        ShiftControl = 3'b000;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;

                        MemToReg = 3'b101;
                        RegDst = 2'b01;
                        RegWR = 1'b1;

                        counter = counter + 1;

                    end else begin

                        MemToReg = 3'b101;
                        RegDst = 2'b01;
                        RegWR = 1'b1;

                        state = fetch;
                        counter = 6'b000000;

                    end

                end

                SRL: begin

                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        AluSrcA = 2'b00;
                        AluSrcB = 3'b000;
                        AluOperation = 3'b000;
                        AluOutWrite = 1'b0;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;

                        reset_out = 1'b0;

                        ShiftControl = 3'b001;
                        ShiftInputControl = 2'b10;
                        ShiftNControl = 2'b10;
                        counter = counter + 1;


                    end else if (counter == 6'b000001)begin

                        ShiftControl = 3'b011;

                        counter = counter + 1;

                    end else if (counter == 6'b000010)begin

                        ShiftControl = 3'b000;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;

                        MemToReg = 3'b101;
                        RegDst = 2'b01;
                        RegWR = 1'b1;

                        counter = counter + 1;

                    end else begin

                        MemToReg = 3'b101;
                        RegDst = 2'b01;
                        RegWR = 1'b1;

                        state = fetch;
                        counter = 6'b000000;

                    end

                end

                RTE: begin

                    IorD = 3'b000;
                    CauseControl = 2'b00;
                    MemWR = 1'b0;
                    IRWrite = 1'b0;
                    RegDst = 2'b00;
                    MemToReg = 3'b000;
                    RegWR = 1'b0;
                    WriteA = 1'b0;
                    WriteB = 1'b0;
                    AluSrcA = 2'b00;
                    AluSrcB = 3'b000;
                    AluOperation = 3'b000;
                    AluOutWrite = 1'b0;
                    EPCWrite = 1'b0;  
                    MemDataWrite = 1'b0;
                    LoadControl = 1'b0;
                    StoreControl = 2'b00;
                    ShiftInputControl = 2'b00;
                    ShiftNControl = 2'b00;
                    ShiftControl = 3'b000;


                    reset_out = 1'b0;

                    PCSource = 3'b101;
                    PCWrite = 1'b1;

                    counter = 6'b000000;
                    state = fetch;


                end

                SLTI: begin
                    if(counter == 6'b000000)begin

                        IRWrite = 1'b0; 
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        AluOutWrite = 1'b0;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 1'b0;
                        CauseControl = 2'b00;
                        IorD = 3'b000;
                        MemWR = 1'b0;
    
                        reset_out = 1'b0;

                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;
                        ShiftInputControl = 2'b00;

                        AluSrcA = 2'b10;
                        AluSrcB = 3'b010;
                        AluOperation = 3'b111;

                        counter = counter + 1;

                    end else if (counter == 6'b000001) begin
                        
                        state = fetch;

                        MemToReg = 3'b100;
                        RegDst = 2'b00;
                        RegWR = 1'b1;
                        
                        
                        counter = 6'b000000;

                    end
                end

                SLT: begin 

                    if(counter == 6'b000000)begin

                        IRWrite = 1'b0; 
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        AluOutWrite = 1'b0;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 1'b0;
                        CauseControl = 2'b00;
                        IorD = 3'b000;
                        MemWR = 1'b0;

    
                        reset_out = 1'b0;

                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;
                        ShiftInputControl = 2'b00;

                        AluSrcA = 2'b10;
                        AluSrcB = 3'b000;
                        AluOperation = 3'b111;

                        counter = counter + 1;

                    end else if (counter == 6'b000001) begin 

                        state = fetch;

                        MemToReg = 3'b100;
                        RegDst = 2'b01;
                        RegWR = 1'b1;
                        
                        
                        counter = 6'b000000;

                    end

                end

                BREAK: begin 

                    if(counter == 6'b000000)begin

                        IRWrite = 1'b0; 
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        AluOutWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 1'b0;
                        CauseControl = 2'b00;
                        IorD = 3'b000;
                        MemWR = 1'b0;
    
                        reset_out = 1'b0;

                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;
                        ShiftInputControl = 2'b00;

                        AluSrcA = 2'b00;
                        AluSrcB = 3'b001;
                        AluOperation = 3'b010;
                        PCSource = 3'b010;
                        PCWrite = 1'b1;

                        counter = 6'b000000;
                        state = fetch;

                    end
                end   

                BEQ: begin

                    if(counter == 6'b000000) begin

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        AluOutWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;

                        reset_out = 1'b0;

                        AluSrcA = 2'b10;
                        AluSrcB = 3'b000;
                        AluOperation = 3'b111;

                        counter  = counter + 1;

                    end else if(counter == 6'b000001)begin

                        if(ET == 1'b1)begin

                            PCSource = 3'b100;
                            PCWrite = 1'b1;

                            counter = 6'b000000;
                            state = fetch;

                        end else begin

                            AluSrcA = 2'b00;
                            AluSrcB = 3'b000;
                            AluOperation = 3'b000;

                            counter = 6'b000000;
                            state = fetch;

                        end

                    end
                    
                end  

                BNE: begin

                    if(counter == 6'b000000) begin

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        AluOutWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;

                        reset_out = 1'b0;

                        AluSrcA = 2'b10;
                        AluSrcB = 3'b000;
                        AluOperation = 3'b111;

                        counter  = counter + 1;

                    end else if(counter == 6'b000001)begin

                        if(ET == 1'b0)begin

                            PCSource = 3'b100;
                            PCWrite = 1'b1;

                            counter = 6'b000000;
                            state = fetch;

                        end else begin

                            AluSrcA = 2'b00;
                            AluSrcB = 3'b000;
                            AluOperation = 3'b000;

                            counter = 6'b000000;
                            state = fetch;

                        end

                    end

                end

                BLE: begin

                    if(counter == 6'b000000) begin

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        AluOutWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;

                        reset_out = 1'b0;

                        AluSrcA = 2'b10;
                        AluSrcB = 3'b000;
                        AluOperation = 3'b111;

                        counter  = counter + 1;

                    end else if(counter == 6'b000001)begin

                        if(ET == 1'b1 || LT == 1'b1)begin

                            PCSource = 3'b100;
                            PCWrite = 1'b1;

                            counter = 6'b000000;
                            state = fetch;

                        end else begin

                            AluSrcA = 2'b00;
                            AluSrcB = 3'b000;
                            AluOperation = 3'b000;

                            counter = 6'b000000;
                            state = fetch;

                        end

                    end                    

                end

                BGT: begin

                    if(counter == 6'b000000) begin

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        AluOutWrite = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;

                        reset_out = 1'b0;

                        AluSrcA = 2'b10;
                        AluSrcB = 3'b000;
                        AluOperation = 3'b111;

                        counter  = counter + 1;

                    end else if(counter == 6'b000001)begin

                        if(GT == 1'b1)begin

                            PCSource = 3'b100;
                            PCWrite = 1'b1;

                            counter = 6'b000000;
                            state = fetch;

                        end else begin

                            AluSrcA = 2'b00;
                            AluSrcB = 3'b000;
                            AluOperation = 3'b000;

                            counter = 6'b000000;
                            state = fetch;

                        end

                    end                    

                end
                
                JR: begin

                    IRWrite = 1'b0; 
                    WriteA = 1'b0;
                    WriteB = 1'b0;
                    AluOutWrite = 1'b0;
                    EPCWrite = 1'b0;  
                    MemDataWrite = 1'b0;
                    LoadControl = 1'b0;
                    StoreControl = 1'b0;
                    CauseControl = 2'b00;
                    IorD = 3'b000;
                    MemWR = 1'b0;
                    AluSrcA = 2'b00;
                    AluSrcB = 3'b000;
                    AluOperation = 3'b000;
                    reset_out = 1'b0;
                    ShiftNControl = 2'b00;
                    ShiftControl = 3'b000;
                    ShiftInputControl = 2'b00;
                    MemToReg = 3'b000;
                    RegDst = 2'b00;
                    RegWR = 1'b0;

                    reset_out = 1'b0;

                    PCSource = 3'b001;
                    PCWrite = 1'b1;

                    state = fetch;

                    counter = 6'b000000;

                end

                J: begin

                    IorD = 3'b000;
                    CauseControl = 2'b00;
                    MemWR = 1'b0;
                    IRWrite = 1'b0;
                    RegDst = 2'b00;
                    MemToReg = 3'b000;
                    RegWR = 1'b0;
                    WriteA = 1'b0;
                    WriteB = 1'b0;
                    AluSrcA = 2'b00;
                    AluSrcB = 3'b000;
                    AluOperation = 3'b000;
                    AluOutWrite = 1'b0;
                    EPCWrite = 1'b0;  
                    MemDataWrite = 1'b0;
                    LoadControl = 1'b0;
                    StoreControl = 2'b00;
                    ShiftInputControl = 2'b00;
                    ShiftNControl = 2'b00;
                    ShiftControl = 3'b000;

                    reset_out = 1'b0;

                    PCSource = 3'b011;
                    PCWrite = 1'b1;

                    counter = 6'b000000;
                    state = fetch;                    

                end

                JAL: begin

                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        CauseControl = 2'b00;
                        MemWR = 1'b0;
                        IRWrite = 1'b0;
                        RegDst = 2'b00;
                        MemToReg = 3'b000;
                        RegWR = 1'b0;
                        WriteA = 1'b0;
                        WriteB = 1'b0;
                        EPCWrite = 1'b0;  
                        MemDataWrite = 1'b0;
                        LoadControl = 1'b0;
                        StoreControl = 2'b00;
                        ShiftInputControl = 2'b00;
                        ShiftNControl = 2'b00;
                        ShiftControl = 3'b000;
                        PCSource = 3'b000;
                        PCWrite = 1'b0;   

                        reset_out = 1'b0;

                        AluSrcA = 2'b00;
                        AluSrcB = 3'b001;
                        AluOperation = 3'b000;
                        AluOutWrite = 1'b1;                        

                        counter = counter + 1;
                        
                    end else begin

                        RegDst = 2'b10;
                        MemToReg = 3'b011;
                        PCSource = 3'b011;
                        RegWR =  1'b1;
                        PCWrite = 1'b1;

                        AluSrcA = 2'b00;
                        AluSrcB = 3'b000;
                        AluOperation = 3'b000;
                        AluOutWrite = 1'b0;

                        counter = 6'b000000;
                        state = fetch; 

                    end

                end


            endcase

        end

    end

endmodule