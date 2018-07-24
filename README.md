TODO Transform roman numerals into L_NUMBER. e.g.:

    Hashtable<Character, Integer> ht = new Hashtable<Character, Integer>();
        ht.put('i',1);
        ht.put('x',10);
        ht.put('c',100);
        ht.put('m',1000);
        ht.put('v',5);
        ht.put('l',50);
        ht.put('d',500);
    then the logic gets pretty simple going by digit right to left
        
    public static int rtoi(String num)
    {       
        int intNum=0;
        int prev = 0;
        for(int i = num.length()-1; i>=0 ; i--)
        {
                int temp = ht.get(num.charAt(i));
                if(temp < prev)
                    intNum-=temp;
                else
                    intNum+=temp;
                prev = temp;
        }
        return intNum;
    }

