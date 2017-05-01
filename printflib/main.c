void PhilPrintf(char* formatString, ...);

int main(void)
{
    PhilPrintf("I love %s very much and %s loves me too %d(%x(%o(%b))) times, %c, %s"
               ", %x, %d, %%\n",
               "EDA", "printf", 100, 100, 100, 100, 'I', "LOVE", 3802, 100);
    return 0;
}
