#include <windows.h> // CreateFileMapping, MapViewOfFile
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <conio.h> // kbhit, getch
#include <unistd.h> // sleep

#define STR_BUF_MAX (16)

typedef struct {
	uint8_t dpsw_in;
	uint8_t led_out;
	// bit field for input
	uint8_t pin_reset : 1;
	uint8_t pin_wait : 1;
	uint8_t pin_nmi : 1;
	uint8_t reserved1 : 5;
	// bit field for output
	uint8_t pin_halt : 1;
	uint8_t reserved2 : 7;
} io_t;

static HANDLE hMap;
static io_t *io_info;

static int shmem_open(void);
static void shmem_close(void);
static int conv_hex(char c);
static void cmd_help(void);

void main(void) {
	io_t io_info_prev;
	int dpsw_in;
	char str_buf[STR_BUF_MAX];
	int value;

	// initialize variable
	memset(&io_info_prev, 0, sizeof(io_t));

	// share memory open
	if (shmem_open() != 0) {
		// failure occurred
		return;
	}

	// command help message
	cmd_help();

	// set print evet
	io_info_prev.dpsw_in = ~io_info->dpsw_in;

	// execute clock cycles
	while (true) {
		// check key input
		if (kbhit()) {
			char key = tolower(getch());
			switch (key) {
			case '?':
				// command help message
				cmd_help();
				break;
			case 's':
				printf("]SW=");
				fgets(str_buf, STR_BUF_MAX, stdin);
				if ((value = conv_hex(str_buf[0])) >= 0) {
					io_info->dpsw_in = value;
					if ((value = conv_hex(str_buf[1])) >= 0) {
						io_info->dpsw_in = (io_info->dpsw_in << 4) + value;
					}
				}
				break;
			case 'r':
				printf("]Reset?(y/n)=");
				if (tolower(getche()) == 'y') {
					io_info->pin_reset = 1;
				}
				printf("\n");
				break;
			case 'w':
				io_info->pin_wait = ~io_info->pin_wait;
				break;
			case 'n':
				io_info->pin_nmi = ~io_info->pin_nmi;
				break;
			default:
				printf("Error\n");
				break;
			}
			// set print evet
			io_info_prev.dpsw_in = ~io_info->dpsw_in;
		}

		// print io value
		if (memcmp(io_info, &io_info_prev, sizeof(io_t)) != 0) {
			printf("SW=%02X[", io_info->dpsw_in);
			for (int i = 7; i >= 0; i--) {
				((io_info->dpsw_in >> i) & 0x01) ? printf("I") : printf(".");
			}
			printf("] LED=%02X[", io_info->led_out);
			for (int i = 7; i >= 0; i--) {
				((io_info->led_out >> i) & 0x01) ? printf("O") : printf(".");
			}
			printf("]");
			if (io_info->pin_wait != 0) {
				printf(" WAIT");
			}
			if (io_info->pin_nmi != 0) {
				printf(" NMI");
			}
			if (io_info->pin_halt != 0) {
				printf(" HALT");
			}
			printf("\n");
		}

		// save previous value
		io_info_prev = *io_info;

		// wait 10ms
		usleep(10000);
	}

	// share memory close
	shmem_close();
}

// share memory open
static int shmem_open(void) {
	HANDLE hMap = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, sizeof(io_t), "z80_aki80_mon2");
	if (!hMap) {
		printf("CreateFileMapping failed: %lu\n", GetLastError());
		return 1;
	}
	io_info = (io_t *)MapViewOfFile(hMap, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(io_t));
	if (!io_info) {
		printf("MapViewOfFile failed: %lu\n", GetLastError());
		CloseHandle(hMap);
		return 1;
	}

	return 0;
}

// share memory close
static void shmem_close(void) {
	UnmapViewOfFile(io_info);
	CloseHandle(hMap);
}

// convert char to hex
static int conv_hex(char c) {
	int value = 0;

	char code = tolower(c);
	if (('0' <= code) && (code <= '9')) {
		value = code - '0';
	}
	else if (('a' <= code) && (code <= 'f')) {
		value = code - 'a' + 10;
	}
	else {
		value = -1;
	}

	return value;
}

// command help message
static void cmd_help(void) {
	printf("? :command Help\n");
	printf("S :set SW\n");
	printf("R :go Reset\n");
	printf("W :toggle Wait\n");
	printf("N :toggle Nmi\n");
}
