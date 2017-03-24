void PhilPrintf(char* formatString, ...);

int main(void)
{
    PhilPrintf("I love %s very much and %s loves me too %d(%x(%o(%b))) times\n",
               "scanf", "printf", 100, 100, 100, 100);
    return 0;
}
