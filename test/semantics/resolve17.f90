! Copyright (c) 2018-2019, NVIDIA CORPORATION.  All rights reserved.
!
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
!
!     http://www.apache.org/licenses/LICENSE-2.0
!
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.

module m
  integer :: foo
  !Note: PGI, Intel, and GNU allow this; NAG and Sun do not
  !ERROR: 'foo' is already declared in this scoping unit
  interface foo
  end interface
end module

module m2
  interface s
  end interface
contains
  !ERROR: 's' may not be the name of both a generic interface and a procedure unless it is a specific procedure of the generic
  subroutine s
  end subroutine
end module

module m3
  ! This is okay: s is generic and specific
  interface s
    procedure s2
  end interface
  interface s
    procedure s
  end interface
contains
  subroutine s()
  end subroutine
  subroutine s2(x)
  end subroutine
end module

module m4a
  interface g
    procedure s_real
  end interface
contains
  subroutine s_real(x)
  end
end
module m4b
  interface g
    procedure s_int
  end interface
contains
  subroutine s_int(i)
  end
end
! Generic g should merge the two use-associated ones
subroutine s4
  use m4a
  use m4b
  call g(123)
  call g(1.2)
end

module m5a
  interface g
    procedure s_real
  end interface
contains
  subroutine s_real(x)
  end
end
module m5b
  interface gg
    procedure s_int
  end interface
contains
  subroutine s_int(i)
  end
end
! Generic g should merge the two use-associated ones
subroutine s5
  use m5a
  use m5b, g => gg
  call g(123)
  call g(1.2)
end

module m6a
  interface gg
    procedure sa
  end interface
contains
  subroutine sa(x)
  end
end
module m6b
  interface gg
    procedure sb
  end interface
contains
  subroutine sb(y)
  end
end
subroutine s6
  !ERROR: Generic 'g' may not have specific procedures 'sa' and 'sb' as their interfaces are not distinguishable
  use m6a, g => gg
  use m6b, g => gg
end

module m7a
  interface g
    procedure s1
  end interface
contains
  subroutine s1(x)
  end
end
module m7b
  interface g
    procedure s2
  end interface
contains
  subroutine s2(x, y)
  end
end
module m7c
  interface g
    procedure s3
  end interface
contains
  subroutine s3(x, y, z)
  end
end
! Merge the three use-associated generics
subroutine s7
  use m7a
  use m7b
  use m7c
  call g(1.0)
  call g(1.0, 2.0)
  call g(1.0, 2.0, 3.0)
end

module m8a
  interface g
    procedure s1
  end interface
contains
  subroutine s1(x)
  end
end
module m8b
  interface g
    procedure s2
  end interface
contains
  subroutine s2(x, y)
  end
end
module m8c
  integer :: g
end
! If merged generic conflicts with another USE, it is an error (if it is referenced)
subroutine s8
  use m8a
  use m8b
  use m8c
  !ERROR: Reference to 'g' is ambiguous
  g = 1
end
