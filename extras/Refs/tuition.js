// ArrayOfSchool -> School
// return school with cheapest tuition
// let school1 = ['school name', 28000]
// ArrayOfSchool can't be empty

// function cheapest(arr) {
//   if (arr.length === 1) return arr[0];
//   else return cheaper(arr[0], cheapest(arr.slice(1)));
// }

// // School, School -> School
// // return school with cheaper tuition
// function cheaper(school1, school2) {
//   return school1[1] < school2[1] ? school1 : school2;
// }

// //======================================
// function cheapest(arr) {
//   if (arr.length === 1) return arr[0];
//   else {
//     if (cheaper(arr[0], cheapest(arr.slice(1)))) {
//       return arr[0];
//     } else return cheapest(arr.slice(1));
//   }
// }

// // School, School -> Boolean
// // return true if first school tuition is cheaper
// function cheaper(school1, school2) {
//   return school1[1] < school2[1];
// }

//======================================================

// ArrayOfSchool -> School
// return school with cheapest tuition
// let school1 = ['school name', 28000]
// ArrayOfSchool can't be empty

function cheapest(arr) {
  if (arr.length === 1) return arr[0];
  let min = arr[0];

  for (let i = 1; i < arr.length; i++) {
    if (arr[i][1] < min[1]) min = arr[i];
  }

  return min;
}

console.log(
  cheapest([
    ["a", 17],
    ["b", 18]
  ])
); // ["a", 17]

console.log(
  cheapest([
    ["a", 17],
    ["b", 0],
    ["c", 19]
  ])
); // ["b", 0]
