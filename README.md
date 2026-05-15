# MicroBlaze AXI SPI/I2C Peripheral Design

> AXI4-Lite 기반 SPI/I2C 페리페럴 RTL 설계 및 MicroBlaze SoC 통합

## 📌 프로젝트 개요

SPI와 I2C 통신 프로토콜을 AXI4-Lite 인터페이스로 설계하여 MicroBlaze CPU와 통합한 SoC 프로젝트입니다. Vivado Block Design으로 하드웨어를 구성하고, Vitis IDE에서 Bare-metal C 코드를 작성하여 레지스터 맵을 통해 페리페럴을 제어합니다.

**개발 기간:** 2026.04.21 ~ 2026.05.08  
**타겟 보드:** Basys3 FPGA  

## 🎯 주요 기능

### AXI4-Lite 인터페이스 설계
- **5채널 구조**: Write Address, Write Data, Write Response, Read Address, Read Data
- **Handshake 프로토콜**: VALID/READY 신호 기반 백프레셔 제어
- **레지스터 맵**: Control, Status, TX Data, RX Data

### SPI Master 페리페럴
- 4선 Full Duplex 통신 지원
- CPOL/CPHA 모드 설정 가능
- 클럭 분주비 조정 가능
- 동시 송수신 (MOSI + MISO)

### I2C Master 페리페럴
- 2선 Half Duplex 통신
- 7비트 주소 지정
- Start/Stop 조건 자동 생성
- ACK/NACK 처리

## 🛠 기술 스택

- **HDL**: Verilog, SystemVerilog
- **FPGA 툴**: Xilinx Vivado 2023.2
- **소프트웨어**: Vitis IDE
- **하드웨어**: Basys3 Artix-7 FPGA
- **프로토콜**: AXI4-Lite, SPI, I2C

## 📁 프로젝트 구조

```
microblaze_axi_i2c_spi/
├── rtl/
│   ├── axi_spi_master/
│   │   ├── axi_spi_top.v
│   │   ├── spi_master.v
│   │   └── axi_lite_slave.v
│   └── axi_i2c_master/
│       ├── axi_i2c_top.v
│       ├── i2c_master.v
│       └── axi_lite_slave.v
├── vivado/
│   ├── block_design.tcl
│   └── constraints.xdc
├── vitis/
│   ├── spi_test/
│   │   └── main.c
│   └── i2c_test/
│       └── main.c
└── docs/
    └── register_map.md
```

## 🏗 시스템 아키텍처

### 하드웨어 블록 다이어그램
### 1️⃣ AXI-SPI 상세 구조

<img width="1194" height="427" alt="image" src="https://github.com/user-attachments/assets/d3b17d64-e84d-4ad3-921f-cbad221dab79" />


---

### 2️⃣ AXI-I2C 상세 구조

<img width="788" height="453" alt="image" src="https://github.com/user-attachments/assets/a6f97771-7544-43f6-be7e-8cbd67ee720b" />


---

### 3️⃣ 소프트웨어 레이어드 아키텍처

#### SPI 시스템
<img width="684" height="369" alt="image" src="https://github.com/user-attachments/assets/268dcea5-2023-4ccb-bfa4-da756de5fb89" />

**4계층 구조:**
- **Application Layer**: 메인 애플리케이션 로직
- **Driver Layer**: FND, Button, Switch 제어 및 SPI 전송 함수
- **HAL Layer**: GPIO/SPI 하드웨어 추상화 계층
- **Hardware Layer**: AXI GPIO, AXI SPI IP 페리페럴

---

#### I2C 시스템

<img width="974" height="531" alt="image" src="https://github.com/user-attachments/assets/654e2c3f-b04e-4904-b74a-4e7e0fcedfd5" />

**4계층 구조:**
- **Application Layer**: UpCounter 메인 태스크, 타이머 인터럽트 핸들러
- **Driver Layer**: I2C Read/Write, Button/FND 드라이버
- **HAL Layer**: I2C.c, GPIO.c, TMR.c (레지스터 제어)
- **Hardware Layer**: AXI I2C, AXI GPIO, AXI TMR 페리페럴
- 
### 레지스터 맵

#### AXI-SPI 레지스터
| 오프셋 | 레지스터 | 설명 |
|--------|----------|------|
| 0x00 | CTRL | [0] EN, [1] CPOL, [2] CPHA |
| 0x04 | STATUS | [0] BUSY, [1] DONE |
| 0x08 | TX_DATA | 송신 데이터 (8비트) |
| 0x0C | RX_DATA | 수신 데이터 (8비트) |
| 0x10 | CLK_DIV | SPI 클럭 분주비 |

#### AXI-I2C 레지스터
| 오프셋 | 레지스터 | 설명 |
|--------|----------|------|
| 0x00 | CTRL | [0] EN, [1] START, [2] STOP |
| 0x04 | STATUS | [0] BUSY, [1] ACK, [2] NACK |
| 0x08 | ADDR | 슬레이브 주소 (7비트) + R/W |
| 0x0C | TX_DATA | 송신 데이터 (8비트) |
| 0x10 | RX_DATA | 수신 데이터 (8비트) |

## 🚀 빌드 및 실행

### 1. Vivado 프로젝트 생성
```tcl
# Vivado GUI에서
File → Open Block Design → block_design.bd
Tools → Run Implementation
Generate Bitstream
```

### 2. Vitis 프로젝트 빌드
```bash
# Vitis IDE에서
File → Import → Vitis project
Build Project (Ctrl+B)
```

### 3. FPGA 다운로드
```
Vivado: Flow → Program and Debug → Program Device
Vitis: Run → Debug (F11) or Run (Ctrl+F11)
```

## 📊 테스트 결과

### SPI 통신 테스트
```c
// Master → Slave 데이터 송신
Xil_Out32(SPI_BASE + TX_DATA, 0xD5);
Xil_Out32(SPI_BASE + CTRL, 0x01);  // Start

// Slave → Master 데이터 수신
while(Xil_In32(SPI_BASE + STATUS) & 0x01);  // Wait BUSY
rx_data = Xil_In32(SPI_BASE + RX_DATA);
```

**결과:**
- 송신: 0xD5 (1101_0101)
- 수신: 0x2C (0010_1100)
- ✅ Full Duplex 동시 교환 성공

### I2C 통신 테스트
```c
// Write 동작
Xil_Out32(I2C_BASE + ADDR, 0x24);   // Addr 0x12 + W
Xil_Out32(I2C_BASE + TX_DATA, 0xAA);
Xil_Out32(I2C_BASE + CTRL, 0x03);   // START + EN

// Read 동작
Xil_Out32(I2C_BASE + ADDR, 0x25);   // Addr 0x12 + R
Xil_Out32(I2C_BASE + CTRL, 0x03);
rx_data = Xil_In32(I2C_BASE + RX_DATA);
```

**결과:**
- Write 데이터: 0xAA
- Read 데이터: 0xAA
- ✅ ACK 수신, 데이터 일치 확인

### Basys3 보드 검증
- LED로 송수신 데이터 확인
- UART로 디버그 메시지 출력
- 스위치로 테스트 모드 전환

## 🔧 Troubleshooting

### 1. 래치(Latch) 발생 문제

**문제:**  
I2C의 `tx_byte_sel` 신호를 `always_comb` 조합 논리로 구현하면서 모든 조건을 커버하지 못해 래치가 발생했습니다.

**해결:**  
```systemverilog
// Before (조합 논리 - 래치 발생)
always_comb begin
    case(state)
        ADDR: tx_byte_sel = 1'b0;
        DATA: tx_byte_sel = 1'b1;
        // default 없음 → 래치!
    endcase
end

// After (순차 논리)
always_ff @(posedge clk) begin
    case(state)
        ADDR: tx_byte_sel <= 1'b0;
        DATA: tx_byte_sel <= 1'b1;
        default: tx_byte_sel <= 1'b0;
    endcase
end
```

### 2. AXI Handshake 타이밍 이슈

**문제:**  
VALID 신호를 너무 빨리 내려서 데이터 손실 발생

**해결:**  
READY 응답을 받은 후에 VALID를 deassert하도록 수정

```verilog
always_ff @(posedge clk) begin
    if(axi_wvalid && axi_wready)
        axi_wvalid <= 1'b0;  // READY 확인 후 내림
end
```

## 📚 배운 점

### 1. AXI4-Lite 프로토콜
- 5채널 handshake 메커니즘 이해
- 백프레셔 제어의 중요성
- Address Editor를 통한 메모리 맵 관리

### 2. SoC 통합 경험
- Vivado Block Design 워크플로우
- Custom IP 생성 및 패키징
- MicroBlaze와 페리페럴 연동

### 3. 하드웨어-소프트웨어 인터페이스
- 레지스터 맵 기반 제어
- Bare-metal 프로그래밍
- 타이밍 제약 및 디버깅

## 🎓 향후 개선 방향

- [ ] DMA 컨트롤러 추가 (고속 데이터 전송)
- [ ] AXI4-Stream 인터페이스 지원
- [ ] 인터럽트 기반 제어
- [ ] FIFO 버퍼 추가 (연속 전송)
- [ ] Multi-master I2C 지원

## 🔗 관련 레포지토리

- **UVM 검증**: [별도 레포지토리 링크]

## 📄 참고 자료

- [AXI4-Lite Specification](https://developer.arm.com/documentation/ihi0022/latest)
- [SPI Protocol](https://www.analog.com/en/analog-dialogue/articles/introduction-to-spi-interface.html)
- [I2C Specification](https://www.nxp.com/docs/en/user-guide/UM10204.pdf)
- [MicroBlaze Reference Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2023_2/ug984-vivado-microblaze-ref.pdf)

## 📄 라이선스

이 프로젝트는 개인 학습 목적으로 작성되었습니다.

---

**Contact**: [GitHub](https://github.com/yeoinseok)
