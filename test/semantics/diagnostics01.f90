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

! Tests semantics diagnostic messages for flangd.

integer :: x
real :: x
integer(8) :: i
parameter(i=1,j=2,k=3)
integer :: j
real :: k
end

! RUN: ${F18} -fflangd-diagnostic %s 2>&1 | ${FileCheck} %s
! CHECK:.*diagnostics01.f90:18,9:18,10:error:The type of 'x' has already been declared
! CHECK:.*diagnostics01.f90:22,9:22,10:error:The type of 'k' has already been implicitly declared
