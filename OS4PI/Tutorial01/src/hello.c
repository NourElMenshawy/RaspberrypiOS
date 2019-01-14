#define UART_BASE	0x09000000

int puts(const char *str)
{
	while (*str)
		*((unsigned int *) UART_BASE) = *str++;
	return 0;
}

void kernel_main(void)
{
	puts("Hello\n");
	while (1);
}
