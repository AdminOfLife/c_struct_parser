struct message1{
  int field1;
  char field2;
};

struct message2{
  int field1;
  double field2;
  struct message1 field3;
};

int foo(void);

//GistID:9e1c7fcfaf744171eab3
