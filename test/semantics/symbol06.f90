! Copyright (c) 2018, NVIDIA CORPORATION.  All rights reserved.
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

!DEF: /main MainProgram
program main
 !DEF: /main/t1 DerivedType
 type :: t1
  !DEF: /main/t1/a1 ObjectEntity INTEGER(4)
  integer :: a1
 end type
 !REF: /main/t1
 !DEF: /main/t2 DerivedType
 type, extends(t1) :: t2
  !DEF: /main/t2/a2 ObjectEntity INTEGER(4)
  integer :: a2
 end type
 !REF: /main/t2
 !DEF: /main/t3 DerivedType
 type, extends(t2) :: t3
  !DEF: /main/t3/a3 ObjectEntity INTEGER(4)
  integer :: a3
 end type
 !REF: /main/t3
 !DEF: /main/x3 ObjectEntity TYPE(t3)
 type(t3) :: x3
 !DEF: /main/i ObjectEntity INTEGER(4)
 integer i
 !REF: /main/i
 !REF: /main/x3
 !REF: /main/t2/a2
 i = x3%a2
 !REF: /main/i
 !REF: /main/x3
 !REF: /main/t1/a1
 i = x3%a1
 !REF: /main/i
 !REF: /main/x3
 !DEF: /main/t3/t2 (ParentComp) ObjectEntity TYPE(t2)
 !REF: /main/t2/a2
 i = x3%t2%a2
 !REF: /main/i
 !REF: /main/x3
 !REF: /main/t3/t2
 !REF: /main/t1/a1
 i = x3%t2%a1
 !REF: /main/i
 !REF: /main/x3
 !DEF: /main/t2/t1 (ParentComp) ObjectEntity TYPE(t1)
 !REF: /main/t1/a1
 i = x3%t1%a1
 !REF: /main/i
 !REF: /main/x3
 !REF: /main/t3/t2
 !REF: /main/t2/t1
 !REF: /main/t1/a1
 i = x3%t2%t1%a1
end program

!DEF: /m1 Module
module m1
 !DEF: /m1/t1 PUBLIC DerivedType
 type :: t1
  !DEF: /m1/t1/t1 ObjectEntity INTEGER(4)
  integer :: t1
 end type
end module

!DEF: /s1 (Subroutine) Subprogram
subroutine s1
 !REF: /m1
 !DEF: /s1/t2 Use
 !REF: /m1/t1
 use :: m1, only: t2 => t1
 !REF: /s1/t2
 !DEF: /s1/t3 DerivedType
 type, extends(t2) :: t3
 end type
 !REF: /s1/t3
 !DEF: /s1/x ObjectEntity TYPE(t3)
 type(t3) :: x
 !DEF: /s1/i ObjectEntity INTEGER(4)
 integer i
 !REF: /s1/i
 !REF: /s1/x
 !REF: /m1/t1/t1
 i = x%t1
 !REF: /s1/i
 !REF: /s1/x
 !DEF: /s1/t3/t2 (ParentComp) ObjectEntity TYPE(t1)
 !REF: /m1/t1/t1
 i = x%t2%t1
end subroutine
