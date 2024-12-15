char *video_mem = (char *) 0xb8000;
int position = 0;

void print(char *message, int color, int len)
{
    for (int i = 0; i < len; i++)
    {
        video_mem[position] = message[i];
        video_mem[position + 1] = color;
        position = position + 2;
    }
}

extern void main() {
    int color0 = 0x00;
    int color1 = 0x06;
    int color2 = 0x09;
    int color3 = 0x0b;

    char *video_mem = (char *) 0xb8000;
    print("Hello", color3, 5);
    print(", ", color1, 2);
    print("kernel", color2, 6);
    print(", ", color1, 2);
    print("from ", color3, 5);
    print("32 ", color2, 3);
    print("bits", color3, 4);
    print("!", color1, 1);

}