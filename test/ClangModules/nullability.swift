// RUN: %target-swift-frontend(mock-sdk: %clang-importer-sdk) -parse -I %S/Inputs/custom-modules %s -import-underlying-module -verify

// REQUIRES: objc_interop

import CoreCooling

func testSomeClass(_ sc: SomeClass, osc: SomeClass?) {
  let ao1: AnyObject = sc.methodA(osc)
  _ = ao1
  if sc.methodA(osc) == nil { }

  let ao2: AnyObject = sc.methodB(nil)
  _ = ao2
  if sc.methodA(osc) == nil { }

  let ao3: AnyObject = sc.property // expected-error{{value of optional type 'AnyObject?' not unwrapped; did you mean to use '!' or '?'?}} {{35-35=!}}
  _ = ao3
  let ao3_ok: AnyObject? = sc.property // okay
  _ = ao3_ok

  let ao4: AnyObject = sc.methodD()
  _ = ao4
  if sc.methodD() == nil { }

  sc.methodE(sc)
  sc.methodE(osc) // expected-error{{value of optional type 'SomeClass?' not unwrapped; did you mean to use '!' or '?'?}} {{17-17=!}}

  sc.methodF(sc, second: sc)
  sc.methodF(osc, second: sc) // expected-error{{value of optional type 'SomeClass?' not unwrapped; did you mean to use '!' or '?'?}} {{17-17=!}}
  sc.methodF(sc, second: osc) // expected-error{{value of optional type 'SomeClass?' not unwrapped; did you mean to use '!' or '?'?}} {{29-29=!}}

  sc.methodG(sc, second: sc)
  sc.methodG(osc, second: sc) // expected-error{{value of optional type 'SomeClass?' not unwrapped; did you mean to use '!' or '?'?}} {{17-17=!}}
  sc.methodG(sc, second: osc) 

  let ci: CInt = 1
  let sc2 = SomeClass(int: ci)
  let sc2a: SomeClass = sc2
  _ = sc2a
  if sc2 == nil { }

  let sc3 = SomeClass(double: 1.5)
  if sc3 == nil { } // okay
  let sc3a: SomeClass = sc3 // expected-error{{value of optional type 'SomeClass?' not unwrapped}} {{28-28=!}}
  _ = sc3a

  let sc4 = sc.returnMe()
  let sc4a: SomeClass = sc4
  _ = sc4a
  if sc4 == nil { }
}

// Nullability with CF types.
func testCF(_ fridge: CCRefrigerator) {
  CCRefrigeratorOpenDoSomething(fridge) // okay
  CCRefrigeratorOpenDoSomething(nil) // expected-error{{nil is not compatible with expected argument type 'CCRefrigerator'}}

  CCRefrigeratorOpenMaybeDoSomething(fridge) // okay
  CCRefrigeratorOpenMaybeDoSomething(nil) // okay

  CCRefrigeratorOpenMaybeDoSomething(5) // expected-error{{cannot convert value of type 'Int' to expected argument type 'CCRefrigerator?'}}
}
