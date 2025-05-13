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
} io_t;

static HANDLE hMap;
static io_t *io_info;

static int shmem_open(void);
static void shmem_close(void);
static int conv_hex(char c);

void main(void) {
	io_t io_info_prev;
	int dpsw_in;
	char str_buf[STR_BUF_MAX];
	int value;

	// initialize
	memset(&io_info_prev, 0, sizeof(io_t));

	// share memory open
	if (shmem_open() != 0) {
		// failure occurred
		return;
	}

	// set print evet
	io_info_prev.dpsw_in = ~(io_info->dpsw_in);

	// execute clock cycles
	while (true) {
		// check key input
		if (kbhit()) {
			getch();
			printf("]SW=");
			fgets(str_buf, STR_BUF_MAX, stdin);
			if ((value = conv_hex(str_buf[0])) >= 0) {
				io_info->dpsw_in = value;
				if ((value = conv_hex(str_buf[1])) >= 0) {
					io_info->dpsw_in = (io_info->dpsw_in << 4) + value;
				}
			}
			// set print evet
			io_info_prev.dpsw_in = ~(io_info->dpsw_in);
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
			printf("]\n");
		}

		// save previous value
		io_info_prev = *io_info;

		// wait 0.5s
		sleep(0.5);
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
