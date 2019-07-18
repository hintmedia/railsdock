#include "railsdock.h"

VALUE rb_mRailsdock;

void
Init_railsdock(void)
{
  rb_mRailsdock = rb_define_module("Railsdock");
}
