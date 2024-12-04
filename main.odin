package main

import "core:fmt"
import "core:os"
import "core:strings"
import "base:runtime"
import "core:slice"
import "core:time"
import "core:strconv"
import "core:unicode/utf8"
import "core:bytes"

test :: true

main :: proc() {
    now := time.now()
    t3()
    fmt.println(time.since(now))
}

loadFile :: proc(num: int) -> string {
    path := test ? fmt.tprintf("inputs/%d_t.txt", num) : fmt.tprintf("inputs/%d.txt", num)

    data, ok := os.read_entire_file(path)
    if !ok {
        fmt.println("error reading file")
        runtime.panic("lol")
    }

    return string(data)
}

t1 :: proc() {
    fmt.println("T1")
    file := loadFile(1)

    lines, _ := strings.split_lines(file)
    left: [dynamic]int
    right: [dynamic]int
    rightAgg := make(map[int]int)

    secondNum := false
    secondInd := 0
    for ch, i in lines[0] {
        if ch >= '0' && ch <= '9' {
        if !secondNum do continue
            secondInd = i
            break
        } else {
            secondNum = true
        }
    }

    for line in lines {
        l, _, _ := fmt._parse_int(line, 0)
        r, _, _ := fmt._parse_int(line, secondInd)
        append(&left, l)
        append(&right, r)
        rightAgg[r] += 1
    }

    slice.sort(left[:])
    slice.sort(right[:])

    sumDiff := 0
    sumAmounts := 0
    for i := 0; i < len(left); i+=1 {
        sumDiff += abs(left[i]-right[i])
        sumAmounts += left[i] * rightAgg[left[i]]
    }

    fmt.println(sumDiff)
    fmt.println(sumAmounts)
}

t2 :: proc() {
    lines := loadFile(2)
    safeCnt := 0
    safeDmpCnt := 0
    for lineRaw in strings.split_lines_iterator(&lines) {
        //        fmt.println()
        line := lineRaw
        if line[len(line)-1] == '\n' {
            line = line[:len(line)-1]
        }
        nums := strings.split(line, " ")


        if checkSafe(nums) {
            safeCnt += 1
        }

        for i := 0; i < len(nums); i += 1 {
            nums2 : [dynamic]string
            append(&nums2, ..nums[:i])
            append(&nums2, ..nums[i+1:])
            if checkSafe(nums2[:]) {
                safeDmpCnt += 1
                break
            }
        }
    }
    fmt.println(safeCnt)
    fmt.println(safeDmpCnt)
}
checkSafe :: proc(nums: []string) -> bool {
    lastNum := -1
    diffDir := 0

    for numRaw in nums {
        num := strconv.atoi(numRaw)
        if lastNum == -1 {
            lastNum = num
            continue
        }

        diff := num - lastNum
        if diffDir == 0 {
            diffDir = sign(diff)
        }
        if sign(diff) != diffDir {
            return false
        }

        diff *= diffDir
        if diff < 1 || diff > 3 {
            return false
        }

        lastNum = num
    }
    return true
}
sign :: proc(inp: int) -> int {
    if inp < 0 {
        return -1
    } else if inp == 0 {
        return 0
    } else {
        return 1
    }
}

t3 :: proc() {
    data := loadFile(3)

    agg := 0
    state := 0
    mul1, mul2 := -1, -1
    mulActive := true

    for index in 0..<len(data) {
        ch := data[index]
//        fmt.printf("%v %v %v ", ch, strconv.atoi(string([]u8{ch})), "")
        switch {
        case ch == "d"[0] && state == 0:
            state = -1
        case ch == "o"[0] && state == -1:
            state = -2
        case ch == "("[0] && state == -2:
            state = -3
        case ch == ")"[0] && state == -3:
            state = 0
            mulActive = true
        case ch == "n"[0] && state == -2:
            state = -4
        case ch == "'"[0] && state == -4:
            state = -5
        case ch == "t"[0] && state == -5:
            state = -6
        case ch == "("[0] && state == -6:
            state = -7
        case ch == ")"[0] && state == -7:
            state = 0
            mulActive = false
        case ch == "m"[0] && state == 0 && mulActive:
//            fmt.print(1)
            state = 1
        case ch == "u"[0] && state == 1:
//            fmt.print(2)
            state = 2
        case ch == "l"[0] && state == 2:
//            fmt.print(3)
            state = 3
        case ch == "("[0] && state == 3:
//            fmt.print(4)
            state = 4
        case ch >= "0"[0] && ch <= "9"[0]:
            if state == 4 {
//                fmt.print("!")
                if mul1 == -1 do mul1 = 0
                mul1 = 10*mul1 + int(ch)-48
            } else if state == 5 {
//                fmt.print("?")
                if mul2 == -1 do mul2 = 0
                mul2 = 10*mul2 + int(ch)-48
            }
        case ch == ","[0] && state == 4 && mul1 != -1:
//            fmt.print("5")
            state = 5
        case ch == ")"[0] && state == 5 && mul2 != -1:
            //all valid
//            fmt.printf("=")
            agg += mul1 * mul2
            fallthrough
        case:
//            fmt.print("_")
            state = 0
            mul1, mul2 = -1, -1
        }
    }

    fmt.println()
    fmt.println(agg)
}