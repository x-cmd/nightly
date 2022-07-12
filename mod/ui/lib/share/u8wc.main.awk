{
    if (length($0) > 1) {
        next
    }

    if (u8wc($0)) printf( "%s - %s - %s - %s - %s\n", U8WC_LEN, U8WC_NAME, U8WC_TYPE, ord(U8WC_VALUE), U8WC_VALUE)
}