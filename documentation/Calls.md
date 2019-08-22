<!--
Copyright (c) 2019, NVIDIA CORPORATION.  All rights reserved.
-->

## Procedure reference implementation protocol

Function and subroutine references are complicated in Fortran.
This document attempts to collect the requirements imposed by the 2018
standard (and legacy extensions) on programs and implementations, work
through the implications of the various features, and propose both a
runtime model and compiler design.

All section, requirement, and constraint numbers herein pertain to
the Fortran 2018 standard.

This note does not consider calls to intrinsic procedures, statement
functions, or calls to internal runtime support library routines.

### Interfaces
Referenced procedures may or may not have declared interfaces
available to their call sites.

Calls to procedures with some post-'77 features require an explicit interface
 (15.4.2.2):
* keyword arguments
* procedures that are `ELEMENTAL` or `BIND(C)`
* procedures that are required to be `PURE` due to the context of the call
  (specification expression, `DO CONCURRENT`, `FORALL`)
* dummy arguments with these attributes: `ALLOCATABLE`, `POINTER`,
  `VALUE`, `TARGET`, `OPTIONAL`, `ASYNCHRONOUS`, `VOLATILE`
* dummy arguments that are coarrays, assumed-shape/-rank,
  parameterized derived types, or polymorphic
* function results that are arrays, `ALLOCATABLE`, `POINTER`,
  or have derived types with parameters that are neither constant nor assumed

Module procedures, internal procedures, procedure pointers,
type-bound procedures, and recursive references by a procedure to itself
always have explicit interfaces.

Other uses of procedures besides calls may also require explicit interfaces,
such as procedure pointer assignment, type-bound procedure bindings, &c.

#### Implicit interfaces
In the absence of any characteristic or context that requires an
explicit interface (see above), a top-level function or subroutine
can be called via its implicit interface.
Each of the arguments can be passed as a simple address, including
dummy procedures.
Procedures that *can* be called via an implicit interface can be checked
by semantics if they have a visible external interface, but must be
compiled as if all calls to them were through the implicit interface.

Procedures that can be called via an implicit interface should respect
the naming conventions and ABI, if any, used for Fortran '77 programs
on the target architecture, so that portable libraries can be compiled
and used by distinct implementations (and versions of implementations)
of Fortran.

Note that functions with implicit interfaces still have known result
types, possibly by means of implicit typing of their names.
They can also be `CHARACTER(*)` assumed-length character functions.

### Protocol overview

Here is a summary script of all of the actions that may need to be taken
by the calling procedure and its referenced procedure to effect
the call, entry, exit, and return steps of the procedure reference
protocol.
The order of these steps is not particularly strict, and we have
some design alternatives that are explored further below.

Before the call:
1. Compute & capture the values of actual argument expressions
   (not designators) into temporary storage.
1. Compact actual argument designator array data into temporaries
   to satisfy contiguity requirements (implicit interface, or
   explicit interface dummy argument not assumed-shape/-rank).
   (`INTENT(OUT)` may only have to allocate and possibly initialize.)
1. Possibly re-initialize `INTENT(OUT)` actual arguments,
   unless they were themselves incoming `INTENT(OUT)` or we decide
   this should always be done in the callee.
1. Some dummy arguments with the `VALUE` attribute could be
   copied here into temporaries in the caller (or forwarded).
1. Create and populate descriptors for assumed-shape/-rank arrays,
   parameterized derived types with length, polymorphic dummy arguments,
   & coarrays.
1. Possibly acquiring/allocating/describing function result storage.
1. Create and populate a descriptor for the function result, if it
   needs one (deferred-shape array, `ALLOCATABLE`, PDT with non-constant
   length parameters, deferred-length `CHARACTER`, &c.).
1. Capture the values of host-escaping local objects in memory;
   package them into single address (for calls to internal procedures &
   for calls that pass internal procedures as arguments).
1. Resolve polymorphic target
1. Marshal actual argument addresses/values
1. Marshal extra arguments for assumed-length `CHARACTER` results,
   function result descriptor, target host variable link, & dummy procedure
   host variable links
1. Jump.

On entry:
1. Shuffle `ENTRY` dummy arguments & jump to common entry point.
1. Complete `VALUE` copying if not always done by the caller.
1. Optionally compact assumed-shape arguments for contiguity
   for SIMD vectorization, if not `TARGET` and not already contiguous.
1. Finalize, deallocate, &/or reinitialize `INTENT(OUT)` arguments
   unless that has been done in the caller.
1. Complete allocation of function result storage, if that has
   not been done by the caller; initialize function result.

Execute the callee, populating the function result or selecting
the subroutine's alternate return.

On exit:
1. Clean up local scope (finalization, deallocation)
1. Deallocate `VALUE` actual argument temporaries.
1. Replace any assumed-shape arguments that were compacted for
   contiguity for SIMD vectorization, if possibly modified
   (and never when `INTENT(IN)`).
1. Identify alternate `RETURN` to caller.
1. Marshal results.
1. Jump

On return to the caller:
1. Copy actual argument array designator data that was copied into
   a temporary for contiguity by the caller back to their original
   home.
1. Complete deallocation of actual argument temporaries.
1. Reload host-escaping locals
1. `GO TO` alternate return, if any
1. Use function result in expression
1. Deallocate function result.

### Target resolution
* polymorphic bindings
* procedure pointers
* dummy procedures
* generic resolution

### Arguments
* `VALUE`
* `OPTIONAL`
* Alternate return specifiers
* `%VAL()` and `%REF()`
* Unrestricted intrinsic functions as actual arguments
* Check definability of `INTENT(OUT)` and `INTENT(IN OUT)` actuals.
#### Temporaries for arguments
* contiguity
* `TARGET`
* allocation, population, reclamation
* transferral of ownership

### Naming
* Modules
* Submodules
* Subprograms
* Mangling explicit interfaces, possibly with versioning

### Function results
* Assumed-length `CHARACTER` results
* Temporaries for result data
