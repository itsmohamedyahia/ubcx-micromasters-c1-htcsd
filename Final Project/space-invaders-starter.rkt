;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname space-invaders-starter) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders Game

;; =================
;; Constants:
;; =================

(define WIDTH  300)
(define HEIGHT 500)

(define INVADER-X-SPEED 1.5)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED 1.5)
(define TANK-SPEED 2)
(define MISSILE-SPEED 10)

(define HIT-RANGE 10)

(define INVADE-RATE 5)  ;Natural from [1,100]

;; Images & related
(define BLANK (square 0 "solid" "white"))
(define BACKGROUND (empty-scene WIDTH HEIGHT))

(define INVADER
  (overlay/xy (ellipse 10 15 "outline" "blue")              ;cockpit cover
              -5 6
              (ellipse 20 10 "solid"   "blue")))            ;saucer

(define INVADER-HEIGHT/2 (/ (image-height INVADER) 2))
(define INVADER-WIDTH/2 (/ (image-width INVADER) 2))

(define TANK
  (overlay/xy (overlay (ellipse 28 8 "solid" "black")       ;tread center
                       (ellipse 30 10 "solid" "green"))     ;tread outline
              5 -14
              (above (rectangle 5 10 "solid" "black")       ;gun
                     (rectangle 20 10 "solid" "black"))))   ;main body

(define TANK-HEIGHT/2 (/ (image-height TANK) 2)) 
(define TANK-WIDTH/2 (/ (image-width TANK) 2))

(define MISSILE (ellipse 5 15 "solid" "red"))


;; =================
;; Data Definitions:
;; =================

(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1

(define TANK-AT-CENTER (make-tank (/ WIDTH 2) 1))                     ;center going right
(define TANK-GO-RT (make-tank 50 1))                                  ;going right
(define TANK-GO-LT (make-tank 50 -1))                                 ;going left
(define TANK-AT-LT-BORDER-GO-LT (make-tank TANK-WIDTH/2 -1))          ;at left border, going left
(define TANK-AT-RT-BORDER-GO-RT (make-tank (- WIDTH TANK-WIDTH/2) 1)) ;at right border, going right
(define TANK-AT-LT-BORDER-GO-RT (make-tank TANK-WIDTH/2 1))           ;at left border, going right
(define TANK-AT-RT-BORDER-GO-LT (make-tank (- WIDTH TANK-WIDTH/2) -1));at right border, going left

#;
(define (fn-for-tank t)
  (... (tank-x t) (tank-dir t)))

;; ------------------
(define-struct invader (x y dx))
;; Invader is (make-invader Number Number Number)
;; interp. the invader is at (x, y) in screen coordinates
;;         the invader along x by dx pixels per clock tick

(define INVADER-NOT-AT-BASE                        ;not landed, moving right        
  (make-invader 150 100 1))       
(define INVADER-AT-BASE
  (make-invader 150 (- HEIGHT INVADER-HEIGHT/2) -1)) ;landed, moving left
(define INVADER-PASSED-BASE
  (make-invader 150 (+ HEIGHT 10) 1))              ;> landed, moving right

#;
(define (fn-for-invader invader)
  (... (invader-x invader) (invader-y invader) (invader-dx invader)))

;; ------------------
(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates

(define M1 (make-missile 150 300))                     

#;
(define (fn-for-missile m)
  (... (missile-x m) (missile-y m)))

;; ------------------
;; Missiles is one of:
;; - empty
;; - (cons Missile Missiles)
;; interp. a list of missiles

(define MISSILES-1 (list (make-missile 50 60)
                         (make-missile 4 10)))

#;
(define (fn-for-missiles lom)
  (cond [(empty? lom) (...)]
        [else
         (... (fn-for-missile (first lom))
              (fn-for-missiles (rest lom)))]))

;; Template rules used:
;; - one of: 2 cases
;; - atomic distinct: empty
;; - compound: (cons Missile Missiles)
;; - self-reference: (rest lom)

;; ------------------
;; Invaders is one of:
;; - empty
;; - (cons Invader Invaders)
;; interp. a list of missiles

(define INVADERS-1 (list (make-invader 50 60 1)))
(define INVADERS-NOT-AT-BASE (list (make-invader 40 0 -1 )
                                           (make-invader 50 50 1)))
(define INVADERS-AT-BASE (list                                           
               (make-invader 40 0 -1)
               (make-invader 50 (- HEIGHT INVADER-HEIGHT/2) 1)))

#;
(define (fn-for-invaders loi)
  (cond [(empty? loi) (...)]
        [else
         (... (fn-for-invader (first loi))
              (fn-for-invaders (rest loi)))]))

;; Template rules used:
;; - one of: 2 cases
;; - atomic distinct: empty
;; - compound: (cons Invader Invader)
;; - self-reference: (rest loi)

;; ------------------
(define-struct game (invaders missiles tank))
;; Game is (make-game  (listof Invader) (listof Missile) Tank)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position
(define GAME-START (make-game empty empty TANK-AT-CENTER))
(define GAME-END (make-game INVADERS-AT-BASE MISSILES-1 TANK-GO-RT))
(define GAME-MID (make-game INVADERS-NOT-AT-BASE MISSILES-1 TANK-GO-LT))

#;
(define (fn-for-game g)
  (... (fn-for-loinvader (game-invaders g))
       (fn-for-lom (game-missiles g))
       (fn-for-tank (game-tank g))))

;; =================
;; Functions:
;; =================
 
;; Game -> Game
;; start the world with (main GAME-START)

(define (main g)
  (big-bang g                ; Game
    (on-tick advance-game)   ; Game -> Game
    (to-draw render)         ; Game -> Image
    (on-key handle-key)      ; Game KeyEvent -> Game
    (stop-when game-over?))) ; Game -> Boolean

;; ------------------
(define TANK-AT-CENTER-ONE-TICK-AFTER
  (make-tank (+ (tank-x TANK-AT-CENTER) TANK-SPEED) 1))

;; Game -> Game
; produce the next game, by updating game data (invaders, missles, tank)
(check-random
 (advance-game GAME-START)
 (make-game (spawn-invaders empty (rand-rate INVADE-RATE))
            empty
            TANK-AT-CENTER-ONE-TICK-AFTER))
(check-random
 (advance-game (make-game
                (list (make-invader 50 75 1))
                (list (make-missile 30 30)
                      (make-missile 50 75))
                (make-tank 50 1)))
 (clean-game (make-game
  (advance-invaders (list (make-invader 50 75 1)))
  (advance-missiles (list (make-missile 30 30)
                          (make-missile 50 75)))
  (advance-tank (make-tank 50 1)))))

            
;(define (advance-game g) g)  ;stub

;; <Template taken from Game>

(define (advance-game g)
  (clean-game (make-game (advance-invaders (game-invaders g))
             (advance-missiles (game-missiles g))
             (advance-tank (game-tank g)))))

;; ------------------
;; Tank -> Tank
;; return new state of tank 
(check-expect (advance-tank TANK-AT-CENTER)                         ;at center, directed to right
              TANK-AT-CENTER-ONE-TICK-AFTER)
(check-expect (advance-tank (make-tank 50 -1))                      ;at center, directed to left        
              (make-tank (- 50 TANK-SPEED) -1))
(check-expect (advance-tank TANK-AT-LT-BORDER-GO-LT)                ;at left border
              (make-tank (+ TANK-SPEED TANK-WIDTH/2) 1))            
(check-expect (advance-tank TANK-AT-RT-BORDER-GO-RT)                ;at right border  
              (make-tank (- (- WIDTH TANK-WIDTH/2) TANK-SPEED) -1))

          
;(define (advance-tank t) t)  ;stub

;; <Template taken from Tank>

(define (advance-tank t)
  (move-tank (divert-tank t)))

;; ------------------
;; Tank -> Tank
;; move tank according to direction inside window
(check-expect (move-tank TANK-AT-CENTER) TANK-AT-CENTER-ONE-TICK-AFTER)        ;at center, going right
(check-expect (move-tank TANK-GO-LT) (make-tank (- 50 TANK-SPEED) -1))         ;at somewhere, going left
(check-expect (move-tank TANK-AT-LT-BORDER-GO-LT) (make-tank TANK-WIDTH/2 -1)) ;at left border, going left
(check-expect (move-tank TANK-AT-RT-BORDER-GO-RT)                              ;at right border, going right
              (make-tank (- WIDTH TANK-WIDTH/2) 1)) 
(check-expect (move-tank (make-tank (+ 1 TANK-WIDTH/2) -1))                    ;going to left border, close
              (make-tank TANK-WIDTH/2 -1))
(check-expect (move-tank (make-tank (- (- WIDTH TANK-WIDTH/2) 1) 1))           ;going to right border, close     
              (make-tank (- WIDTH TANK-WIDTH/2) 1))      

;(define (move-tank t) t)  ;stub

;; <Template taken from Tank>

(define (move-tank t)
  (make-tank (contain-tank (+ (tank-x t) (* TANK-SPEED (tank-dir t)))) (tank-dir t)))

;; ------------------
;; Natural -> Natural[TANK-WIDTH/2, (- WIDTH TANK-WIDTH/2)]
;; if number is: <TANK-WIDTH/2             return   TANK-WIDTH/2,
;;               >(- WIDTH TANK-WIDTH/2)   return   (- WIDTH TANK-WIDTH/2)
;;    otherwise: return number
(check-expect (contain-tank (- TANK-WIDTH/2 1)) TANK-WIDTH/2)
(check-expect (contain-tank 20) 20)
(check-expect (contain-tank (+ (- WIDTH TANK-WIDTH/2) 1)) (- WIDTH TANK-WIDTH/2))

;(define (contain-tank n) n)  ;stub

(define (contain-tank n)
  (cond [(< n TANK-WIDTH/2) TANK-WIDTH/2]
        [(> n (- WIDTH TANK-WIDTH/2)) (- WIDTH TANK-WIDTH/2)]
        [else n]))
;; ------------------
;; Tank -> Tank
;; divert tank direction if it hits a wall
(check-expect (divert-tank TANK-AT-CENTER) TANK-AT-CENTER)                  ;tank away from wall
(check-expect (divert-tank TANK-AT-LT-BORDER-GO-LT) TANK-AT-LT-BORDER-GO-RT);tank at lt wall, looking lt
(check-expect (divert-tank TANK-AT-RT-BORDER-GO-RT) TANK-AT-RT-BORDER-GO-LT);tank at rt wall, looking rt

;(define (divert-tank t) t) ;stub

;; <Template taken from Tank>

(define (divert-tank t)
  (cond [(<= (tank-x t) TANK-WIDTH/2) (make-tank (tank-x t) 1)]
        [(>= (tank-x t) (- WIDTH TANK-WIDTH/2)) (make-tank (tank-x t) -1)]
        [else (make-tank (tank-x t) (tank-dir t))]))

;; ------------------
;; Missiles -> Missiles
;; return new state of missiles
(check-expect (advance-missiles (list (make-missile 30 40)
                                     (make-missile 50 60)))
              (list (make-missile 30 (- 40 MISSILE-SPEED))
                    (make-missile 50 (- 60 MISSILE-SPEED))))
(check-expect (advance-missiles (list (make-missile 30 0)
                                     (make-missile 40 5)
                                     (make-missile 50 11)))
              (list (make-missile 50 1)))

;(define (advance-missiles lom) empty) ;stub

;; <Template taken from Missiles>

(define (advance-missiles lom)
  (clean-missiles (rise-missiles lom)))

;; ------------------
;; Missiles -> Missiles
;; advance missiles upward
(check-expect (rise-missiles empty) empty)
(check-expect (rise-missiles (list (make-missile 30 0)
                                     (make-missile 40 5)
                                     (make-missile 50 11)))
              (list (make-missile 30 (- 0 MISSILE-SPEED))
                    (make-missile 40 (- 5 MISSILE-SPEED))
                    (make-missile 50 (- 11 MISSILE-SPEED))))

;(define (rise-missiles lom) empty)

;; <Template taken from Missiles>

(define (rise-missiles lom)
  (cond [(empty? lom) empty]
        [else
         (cons (rise-missile (first lom))
              (rise-missiles (rest lom)))]))

;; ------------------
;; Missile -> Missile
;; advance missile upward
(check-expect (rise-missile (make-missile 50 60))
              (make-missile 50 (- 60 MISSILE-SPEED)))
(check-expect (rise-missile (make-missile 0 0))
              (make-missile 0 (- 0 MISSILE-SPEED)))

;(define (rise-missile m) m) ;stub

;; <Template taken from Missile>

(define (rise-missile m)
  (make-missile (missile-x m) (- (missile-y m) MISSILE-SPEED)))


;; ------------------
;; Missiles -> Missiles
;; remove missiles that are out of bound (missile-y < HEIGHT)
(check-expect (clean-missiles empty) empty)
(check-expect (clean-missiles (list (make-missile 30 -1)
                                     (make-missile 40 0)
                                     (make-missile 50 11)))
              (list (make-missile 40 0)
                    (make-missile 50 11)))

;(define (clean-missiles lom) empty) ;stub

;; <Template taken from Missiles>

(define (clean-missiles lom)
  (cond [(empty? lom) empty]
        [else
         (if (out-of-bound? (first lom))
             (clean-missiles (rest lom))
             (cons (first lom) (clean-missiles (rest lom))))]))

;; ------------------
;; Missile -> Boolean
;; return true if missile is out of bound
(check-expect (out-of-bound? (make-missile 10 -1)) #true)
(check-expect (out-of-bound? (make-missile 9 0))   #false)
(check-expect (out-of-bound? (make-missile 50 20)) #false)

;(define (out-of-bound? m) #true)

;; <Template taken from Missile>

(define (out-of-bound? m)
  (< (missile-y m) 0))

;; ------------------
;; Invaders -> Invaders
;; return new state of invaders
(check-random (advance-invaders (list (make-invader 10 10 1)
                                     (make-invader 20 20 -1)))
              (spawn-invaders
               (list (make-invader (+ 10 INVADER-X-SPEED) (+ 10 INVADER-Y-SPEED) 1)
                     (make-invader (- 20 INVADER-X-SPEED) (+ 20 INVADER-Y-SPEED) -1))
               (rand-rate INVADE-RATE)))

;(define (advance-invaders loi) empty) ;stub


(define (advance-invaders loi)
  (spawn-invaders (fall-invaders loi) (rand-rate INVADE-RATE)))

;; ------------------
;; Natural[1,100] -> Natural
;; return a random natural less than (/ 100 n) (controlled invade rate)
(check-random (rand-rate 5) (random (/ 100 5)))
(check-random (rand-rate 70) (random (round (/ 100 70))))
               
;(define (rand-rate n) 0)  ;stub

(define (rand-rate n)
  (random (round (/ 100 n))))

;; ------------------
;; Invaders -> Invaders
;; move invaders down in appropriate x, y velocities
(check-expect (fall-invaders empty) empty)
(check-expect (fall-invaders (list (make-invader 0 0 1)
                                   (make-invader 0 100 -1)
                                   (make-invader WIDTH 50 1)))
              (list (make-invader (+ 0 INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) 1)
                    (make-invader (+ 0 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 1)
                    (make-invader (- WIDTH INVADER-X-SPEED) (+ 50 INVADER-Y-SPEED) -1)))


;(define (fall-invaders loi) empty) ;stub

;; <Template taken from Invaders>

(define (fall-invaders loi)
  (cond [(empty? loi) empty]
        [else
         (cons (fall-invader (first loi))
              (fall-invaders (rest loi)))]))

;; ------------------
;; Invader -> Invader
;; move invader down in appropriate x, y velocities
(check-expect (fall-invader (make-invader 0 0 1))
              (make-invader (+ 0 INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) 1))
(check-expect (fall-invader (make-invader 0 0 1))
              (make-invader (+ 0 INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) 1))
(check-expect (fall-invader (make-invader 0 0 1))
              (make-invader (+ 0 INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) 1))

;(define (fall-invader i) i) ;stub

(define (fall-invader i)
  (sink-invader (divert-invader i)))

;; ------------------
;; Invader -> Invader
;; move invader down in y speed and (invader-dx)-based x velocity
(check-expect (sink-invader (make-invader 0 90 1))                      ;at left edge, moving right
              (make-invader
               (+ 0 (* 1 INVADER-X-SPEED)) (+ 90 INVADER-Y-SPEED) 1))
(check-expect (sink-invader (make-invader 0 90 -1))                     ;at left edge, moving left
              (make-invader 0 (+ 90 INVADER-Y-SPEED) -1))         
(check-expect (sink-invader (make-invader WIDTH 90 -1))                 ;at right edge, moving left
              (make-invader
               (+ WIDTH (* -1 INVADER-X-SPEED)) (+ 90 INVADER-Y-SPEED) -1))
(check-expect (sink-invader (make-invader WIDTH 90 1))                  ;at right edge, moving right
              (make-invader WIDTH (+ 90 INVADER-Y-SPEED) 1))
(check-expect (sink-invader (make-invader (+ 10 WIDTH) 90 1))           ;passed right edge, moving right
              (make-invader WIDTH (+ 90 INVADER-Y-SPEED) 1)) 
(check-expect (sink-invader (make-invader (- 0 10) 90 1))               ;passed left edge, moving right
              (make-invader 0 (+ 90 INVADER-Y-SPEED) 1)) 

;(define (sink-invader invader) invader) ;stub

(define (sink-invader invader)
  (make-invader (stop-invader-x (+ (invader-x invader) (* (invader-dx invader) INVADER-X-SPEED)))
                   (+ (invader-y invader) INVADER-Y-SPEED)
                   (invader-dx invader)))

;; ------------------
;; Natural -> Natural[0-WIDTH]
;; return 0 if given num is < 0, return WIDTH if num > WIDTH, else return num
(check-expect (stop-invader-x 9) 9)
(check-expect (stop-invader-x -1) 0)
(check-expect (stop-invader-x (+ WIDTH 10)) WIDTH)
              
;(define (stop-invader-x x) x) ;stub 

(define (stop-invader-x x)
  (cond [(< x 0) 0]
        [(> x WIDTH) WIDTH]
        [else x]))

;; ------------------
;; Invader -> Invader
;; change invader velocity if it hit a wall
(check-expect (divert-invader (make-invader INVADER-WIDTH/2 100 -1))        ;at left border
              (make-invader INVADER-WIDTH/2 100 1)) 
(check-expect (divert-invader (make-invader (- WIDTH INVADER-WIDTH/2) 0 1)) ;at right border
              (make-invader (- WIDTH INVADER-WIDTH/2) 0 -1))
(check-expect (divert-invader (make-invader 100 50 1))                      ; somewhere
              (make-invader 100 50 1))
(check-expect (divert-invader (make-invader INVADER-WIDTH/2 100 1))         ;at left border, in correct direction
              (make-invader INVADER-WIDTH/2 100 1))


;(define (divert-invader i) i) ;stub

; <Template taken from Invader>

(define (divert-invader i)
  (cond [(<= (invader-x i) INVADER-WIDTH/2)
         (make-invader (invader-x i) (invader-y i) 1)]
        [(>= (invader-x i) (- WIDTH INVADER-WIDTH/2))
         (make-invader (invader-x i) (invader-y i) -1)]
        [else 
          (make-invader (invader-x i) (invader-y i) (invader-dx i))]))


;; ------------------
;; Invaders Natural[0,(/ 100 INVADE-RATE)] -> Invaders
;; add new invaders to the list given a rate of spawn
(check-random (spawn-invaders empty 0)
              (list (make-invader (random (- WIDTH INVADER-WIDTH/2)) 0 (rand-dir (random 2)))))
(check-random (spawn-invaders INVADERS-NOT-AT-BASE 0)
              (append (list (make-invader (random (- WIDTH INVADER-WIDTH/2)) 0 (rand-dir (random 2))))
                      INVADERS-NOT-AT-BASE))
(check-random (spawn-invaders empty 4) empty)
(check-random (spawn-invaders INVADERS-NOT-AT-BASE 100)
              INVADERS-NOT-AT-BASE)
;(define (spawn-invaders loi n) (list (make-invader 0 0 0))) ;stub

(define (spawn-invaders loi n)
  (if (zero? n)
      (cons (make-invader (random (- WIDTH INVADER-WIDTH/2))
                          0
                          (rand-dir (random 2)))
            loi)
      loi))

;; ------------------
;; Natural[0,1] -> Direction
;; return -1 if given is 0, otherwise return 1
(check-expect (rand-dir 0) -1)
(check-expect (rand-dir 1) 1)

;(define (rand-dir n) 1)  ;stub

(define (rand-dir n)
  (cond [(zero? n) -1]
        [else 1]))


;; ------------------
;; Game -> Game
;; remove objects (invaders, missiles) that hit/got hit from the game
(check-expect (clean-game (make-game (list (make-invader 50 50 1)
                                           (make-invader 100 100 -1))
                                     (list (make-missile 50 50)
                                           MISSILE-120/120)
                                     TANK-AT-CENTER))
              (make-game (list (make-invader 100 100 -1))
                         (list  MISSILE-120/120)
                         TANK-AT-CENTER))
(check-expect (clean-game (make-game (list (make-invader 40 40 -1)
                                           (make-invader 130 50 1))
                                     (list (make-missile 30 30)
                                           (make-missile 125 50))
                                     TANK-AT-CENTER))
              (make-game empty empty TANK-AT-CENTER))

;(define (clean-game g) empty) ;stub

;; <Template taken from Game>

(define (clean-game g)
  (make-game (kill-invaders (game-invaders g) (game-missiles g))
       (destroy-missiles (game-missiles g) (game-invaders g))
       (game-tank g)))

;; ------------------
;; Invaders Missiles -> Invaders
;; kill invaders that got hit by missiles
(check-expect (kill-invaders (list (make-invader 50 50 1)
                                   (make-invader 100 100 -1))
                             (list (make-missile 50 50)
                                   MISSILE-120/120))
              (list (make-invader 100 100 -1)))
                         
(check-expect (kill-invaders  (list (make-invader 40 40 -1)
                                    (make-invader 130 50 1))
                              (list (make-missile 30 30)
                                    (make-missile 125 50))) empty)
             

;(define (kill-invaders loi lom) loi) ;stub

(define (kill-invaders loi lom)
  (cond [(empty? loi) empty]
        [else
         (if (invader-in-range-missiles? (first loi) lom)
              (kill-invaders (rest loi) lom)
              (cons (first loi) (kill-invaders (rest loi) lom)))]))

;; ------------------
(define INVADER-50/50 (make-invader 50 50 1))
(define INVADER-100/100 (make-invader 100 100 1))
(define MISSILE-50/50 (make-missile 50 50))
(define MISSILE-50/50-X+R (make-missile (+ 50 HIT-RANGE) 50))
(define MISSILE-50/50-Y+R (make-missile 50 (+ 50 HIT-RANGE)))
(define MISSILE-50/50-XY+R(make-missile (+ 50 HIT-RANGE) (+ 50 HIT-RANGE)))
(define MISSILE-50/50-X-R (make-missile (- 50 HIT-RANGE) 50))
(define MISSILE-50/50-Y-R (make-missile 50 (- 50 HIT-RANGE)))
(define MISSILE-50/50-XY-R (make-missile (- 50 HIT-RANGE) (- 50 HIT-RANGE)))
(define MISSILE-100/100 (make-missile 100 100))
(define MISSILE-120/120 (make-missile 120 120))

;; Invader Missiles -> Boolean
;; return true if invader is in range of any of missiles
(check-expect
 (invader-in-range-missiles? INVADER-50/50                          ;exactly on each other
                    (list MISSILE-50/50 MISSILE-100/100)) #true)
(check-expect
 (invader-in-range-missiles? INVADER-50/50    ; missile-x is HIT-RANGE MORE than invader-x
                    (list MISSILE-50/50-X+R MISSILE-100/100)) #true)
(check-expect
 (invader-in-range-missiles? INVADER-50/50
                    (list MISSILE-50/50-Y+R MISSILE-100/100)) #true)
(check-expect
 (invader-in-range-missiles? INVADER-50/50
                    (list MISSILE-50/50-XY+R MISSILE-100/100)) #true)

(check-expect (invader-in-range-missiles? INVADER-50/50
                                 (list MISSILE-50/50-X-R MISSILE-100/100)) #true)
(check-expect (invader-in-range-missiles? INVADER-50/50
                                 (list MISSILE-50/50-Y-R MISSILE-100/100)) #true)
(check-expect (invader-in-range-missiles? INVADER-50/50
                                 (list MISSILE-50/50-XY-R MISSILE-100/100)) #true)

(check-expect (invader-in-range-missiles? INVADER-50/50
                                 (list  MISSILE-120/120
                                       MISSILE-100/100)) #false)

;(define (invader-in-range-missiles? i lom) #false)  ;stub

(define (invader-in-range-missiles? i lom)
  (cond [(empty? lom) #false]
        [else
         (if (invader-in-range-missile? i (first lom))
             #true
              (invader-in-range-missiles? i (rest lom)))]))

;; ------------------
;; Invader Missile -> Boolean
;; return true if invader is in range of missile
(check-expect (invader-in-range-missile? INVADER-50/50 MISSILE-50/50) #true)
(check-expect (invader-in-range-missile? INVADER-50/50 MISSILE-50/50-X+R) #true)
(check-expect (invader-in-range-missile? INVADER-50/50 MISSILE-50/50-Y+R) #true)
(check-expect (invader-in-range-missile? INVADER-50/50 MISSILE-50/50-XY+R) #true)
(check-expect (invader-in-range-missile? INVADER-50/50 MISSILE-50/50-X-R) #true)
(check-expect (invader-in-range-missile? INVADER-50/50 MISSILE-50/50-Y-R) #true)
(check-expect (invader-in-range-missile? INVADER-50/50 MISSILE-50/50-XY-R) #true)
(check-expect (invader-in-range-missile? INVADER-50/50 MISSILE-100/100) #false)


;(define (invader-in-range-missile? i m) #false) ;stub

(define (invader-in-range-missile? i m)
  (and (<= (abs (- (invader-x i) (missile-x m))) HIT-RANGE)
       (<= (abs (- (invader-y i) (missile-y m))) HIT-RANGE)))

;; ------------------
;; Missiles Invaders -> Invaders
;; destroy missiles that hit invaders
(check-expect (destroy-missiles (list (make-missile 50 50)
                                      MISSILE-120/120)
                                (list (make-invader 50 50 1)
                                      (make-invader 100 100 -1)))
              (list MISSILE-120/120))
                         
(check-expect (destroy-missiles  (list (make-missile 30 30)
                                       (make-missile 125 50))
                                 (list (make-invader 40 40 -1)
                                       (make-invader 130 50 1))) empty)

;(define (destroy-missiles lom loi) lom) ;stub

(define (destroy-missiles lom loi)
  (cond [(empty? lom) empty]
        [else
         (if (missile-in-range-invaders? (first lom) loi)
              (destroy-missiles (rest lom) loi)
              (cons (first lom) (destroy-missiles (rest lom) loi)))]))

;; ------------------
;; Missile Invaders -> Boolean
;; return true if missile is in range with any invaders
(check-expect (missile-in-range-invaders? MISSILE-50/50 (list INVADER-50/50
                                                              INVADER-100/100)) #true)
(check-expect (missile-in-range-invaders? MISSILE-50/50-X+R (list INVADER-50/50
                                                              INVADER-100/100)) #true)
(check-expect (missile-in-range-invaders? MISSILE-50/50-X-R (list INVADER-50/50
                                                              INVADER-100/100)) #true)
(check-expect (missile-in-range-invaders? MISSILE-50/50-XY+R (list INVADER-50/50
                                                              INVADER-100/100)) #true)
(check-expect (missile-in-range-invaders? MISSILE-50/50-Y+R (list INVADER-50/50
                                                              INVADER-100/100)) #true)
(check-expect (missile-in-range-invaders? MISSILE-50/50-Y-R (list INVADER-50/50
                                                              INVADER-100/100)) #true)
(check-expect (missile-in-range-invaders? MISSILE-50/50-XY-R (list INVADER-50/50
                                                              INVADER-100/100)) #true)
(check-expect (missile-in-range-invaders? MISSILE-120/120 (list INVADER-50/50
                                                              INVADER-100/100)) #false)
                                          
;(define (missile-in-range-invaders? m loi) #false)  ;stub

(define (missile-in-range-invaders? m loi)
  (cond [(empty? loi) #false]
        [else
         (if  (missile-in-range-invader? m (first loi))
              #true
              (missile-in-range-invaders? m (rest loi)))]))

;; ------------------
;; Missile Invader -> Boolean
;; return true if missile is in range with invader
(check-expect (missile-in-range-invader? MISSILE-50/50 INVADER-50/50) #true)
(check-expect (missile-in-range-invader? MISSILE-50/50-X+R INVADER-50/50) #true)
(check-expect (missile-in-range-invader? MISSILE-50/50-X-R INVADER-50/50) #true)
(check-expect (missile-in-range-invader? MISSILE-50/50-Y+R INVADER-50/50) #true)
(check-expect (missile-in-range-invader? MISSILE-50/50-Y-R INVADER-50/50) #true)
(check-expect (missile-in-range-invader? MISSILE-50/50-XY+R INVADER-50/50) #true)
(check-expect (missile-in-range-invader? MISSILE-50/50-XY-R INVADER-50/50) #true)
(check-expect (missile-in-range-invader? MISSILE-120/120 INVADER-50/50) #false)


;(define (missile-in-range-invader? m i) #false) ;stub

(define (missile-in-range-invader? m i)
  (and (<= (abs (- (missile-x m) (invader-x i))) HIT-RANGE)
       (<= (abs (- (missile-y m) (invader-y i))) HIT-RANGE)))

;; ------------------
(define INVADERS-NOT-AT-BASE-FIRST-POSN
  (make-posn (invader-x (first INVADERS-NOT-AT-BASE))
             (invader-y (first INVADERS-NOT-AT-BASE))))
(define INVADERS-NOT-AT-BASE-SECOND-POSN
  (make-posn (invader-x (first (rest INVADERS-NOT-AT-BASE)))
             (invader-y (first (rest INVADERS-NOT-AT-BASE)))))
(define MISSILES-1-FIRST-POSN
  (make-posn (missile-x (first MISSILES-1))
             (missile-y (first MISSILES-1))))
(define MISSILES-1-SECOND-POSN
  (make-posn (missile-x (first (rest MISSILES-1)))
             (missile-y (first (rest MISSILES-1)))))
(define TANK-GO-RT-POSN
  (make-posn (tank-x TANK-GO-RT) (- HEIGHT TANK-HEIGHT/2)))

;; Game -> Image
;; render current game state
(check-expect (render (make-game empty empty TANK-AT-CENTER))
              (place-images (list TANK)
                            (list (make-posn (tank-x TANK-AT-CENTER)
                                             (- HEIGHT TANK-HEIGHT/2)))
                            BACKGROUND))
(check-expect
 (render (make-game INVADERS-NOT-AT-BASE MISSILES-1 TANK-GO-RT))
 (place-images (list INVADER INVADER MISSILE MISSILE TANK)
               (list INVADERS-NOT-AT-BASE-FIRST-POSN
                     INVADERS-NOT-AT-BASE-SECOND-POSN
                     MISSILES-1-FIRST-POSN
                     MISSILES-1-SECOND-POSN
                     TANK-GO-RT-POSN)
               BACKGROUND))

;(define (render g) BACKGROUND) ;stub

(define (render g)
  (place-images (images g) (posns g) BACKGROUND))

;; ------------------
;; Game -> Images
;; return a list of images of given game in order of game
(check-expect (images (make-game empty empty TANK-GO-RT))
              (list TANK))
(check-expect (images (make-game INVADERS-NOT-AT-BASE MISSILES-1 TANK-AT-CENTER))
              (list INVADER INVADER MISSILE MISSILE TANK))
                          
;(define (images g) empty) ;stub

;; <Template taken from Game>

(define (images g)
  (append (list-n-imgs (length (game-invaders g)) INVADER)
          (list-n-imgs (length (game-missiles g)) MISSILE)
          (list TANK)))

;; ------------------
;; Natural Image -> Images
;; return a list of n images 
(check-expect (list-n-imgs 0 BLANK) empty)
(check-expect (list-n-imgs 2 INVADER) (list INVADER INVADER))
(check-expect (list-n-imgs 3 MISSILE) (list MISSILE MISSILE MISSILE))

;(define (list-n-imgs n img) empty) ;stub

;; <Template taken from Invaders>

(define (list-n-imgs n img)
  (cond [(zero? n) empty]
        [else
         (cons img (list-n-imgs (sub1 n) img))]))
  
;; ------------------
;; Game -> Positions
;; return a list of positions of objects in game
(check-expect (posns (make-game INVADERS-NOT-AT-BASE MISSILES-1 TANK-GO-RT))
              (list INVADERS-NOT-AT-BASE-FIRST-POSN
                     INVADERS-NOT-AT-BASE-SECOND-POSN
                     MISSILES-1-FIRST-POSN
                     MISSILES-1-SECOND-POSN
                     TANK-GO-RT-POSN))
               
;(define (posns g) empty) ;stub

;; <Template taken from Game>

(define (posns g)
  (append (invaders-posns (game-invaders g))
          (missiles-posns (game-missiles g))
          (list (tank-posn (game-tank g)))))

;; ------------------
;; Invaders -> Positions
;; return a list of positions of invaders
(check-expect (invaders-posns empty) empty)
(check-expect (invaders-posns INVADERS-NOT-AT-BASE)
              (list INVADERS-NOT-AT-BASE-FIRST-POSN
                    INVADERS-NOT-AT-BASE-SECOND-POSN))

;(define (invaders-posns loi) empty)  ;stub

;; <Template taken from Invaders>

(define (invaders-posns loi)
  (cond [(empty? loi) empty]
        [else
         (cons (invader-posn (first loi))
              (invaders-posns (rest loi)))]))

;; ------------------
;; Invader -> Position
;; get invader position
(check-expect (invader-posn (make-invader 30 40 -1)) (make-posn 30 40))
(check-expect (invader-posn (make-invader 100 90 1)) (make-posn 100 90))

;(define (invader-posn i) (make-posn 0 0)) ;stub

;; <Template taken from Invader>

(define (invader-posn invader)
  (make-posn (invader-x invader) (invader-y invader)))

;; ------------------
;; Missiles -> Positions
;; return a list of positions for missiles
(check-expect (missiles-posns empty) empty)
(check-expect (missiles-posns MISSILES-1)
              (list MISSILES-1-FIRST-POSN MISSILES-1-SECOND-POSN))

;(define (missiles-posns lom) empty)  ;stub

;; <Template taken from Missiles>

(define (missiles-posns lom)
  (cond [(empty? lom) empty]
        [else
         (cons (missile-posn (first lom))
              (missiles-posns (rest lom)))]))

;; ------------------
;; Missile -> Position
;; return a position for missile
(check-expect (missile-posn (make-missile 10 20)) (make-posn 10 20))
(check-expect (missile-posn (make-missile 100 40)) (make-posn 100 40))

;(define (missile-posn m) (make-posn 0 0))  ;stub

(define (missile-posn m)
  (make-posn (missile-x m) (missile-y m)))

;; ------------------
;; Tank -> Position
;; return a position for tank
(check-expect (tank-posn (make-tank 40 1)) (make-posn 40 (- HEIGHT TANK-HEIGHT/2)))
(check-expect (tank-posn (make-tank 100 -1)) (make-posn 100 (- HEIGHT TANK-HEIGHT/2)))

;(define (tank-posn t) (make-posn 0 0))  ;stub

(define (tank-posn t)
  (make-posn (tank-x t) (- HEIGHT TANK-HEIGHT/2)))

;; ------------------
;; Game KeyEvent -> Game
;; produce new state for given game if space or horizontal arrow keys are pressed
(check-expect (handle-key GAME-START " ")
              (make-game empty
                         (list (make-missile (tank-x TANK-AT-CENTER) (- HEIGHT TANK-HEIGHT/2)))
                         TANK-AT-CENTER))
(check-expect (handle-key (make-game INVADERS-NOT-AT-BASE MISSILES-1 TANK-GO-RT) " ")
              (make-game INVADERS-NOT-AT-BASE
                         (append (list (make-missile (tank-x TANK-GO-RT) (- HEIGHT TANK-HEIGHT/2))) MISSILES-1)
                         TANK-GO-RT))
(check-expect (handle-key GAME-START "right")
              (make-game empty
                         empty
                         TANK-AT-CENTER))
(check-expect (handle-key GAME-START "left")
              (make-game empty
                         empty
                         (make-tank (/ WIDTH 2) -1)))
(check-expect (handle-key GAME-START "w")
              GAME-START)

;(define (handle-key g ke) g) ;stub

(define (handle-key g ke)
  (cond [(key=? ke " ")
         (make-game (game-invaders g)
                    (fire-missile (game-missiles g) (game-tank g))
                    (game-tank g))]
        [(or (key=? ke "left") (key=? ke "right"))
         (make-game (game-invaders g)
                    (game-missiles g)
                    (direct-tank (game-tank g) ke))]
        [else g]))

;; ------------------
;; Tank KeyEvent -> Tank
;; direct tank to the left if key is the left arrow otherwise right
(check-expect (direct-tank TANK-GO-RT "left") TANK-GO-LT)
(check-expect (direct-tank TANK-GO-LT "left") TANK-GO-LT)
(check-expect (direct-tank TANK-GO-LT "right") TANK-GO-RT)

;(define (direct-tank t ke) t) ;stub

(define (direct-tank t ke)
  (if (key=? ke "left") (make-tank (tank-x t) -1) (make-tank (tank-x t) 1)))

;; ------------------
;; Missiles Tank -> Missiles
;; add new missile to list (missile-x = tank-x, missile-y = HEIGHT - TANK-HEIGHT/2)
(check-expect (fire-missile empty TANK-AT-CENTER)
              (list (make-missile (tank-x TANK-AT-CENTER) (- HEIGHT TANK-HEIGHT/2))))
(check-expect (fire-missile MISSILES-1 TANK-AT-CENTER)
              (append (list (make-missile (tank-x TANK-AT-CENTER) (- HEIGHT TANK-HEIGHT/2))) MISSILES-1))

;(define (fire-missile lom t) lom) ;stub

(define (fire-missile lom t)
  (cons (make-missile (tank-x t) (- HEIGHT TANK-HEIGHT/2)) lom))

;; ------------------
;; Game -> Boolean
;; produce true if game is over
(check-expect
 (game-over? (make-game INVADERS-NOT-AT-BASE MISSILES-1 TANK-GO-RT))    ; invader not at base
 #false)
(check-expect                                                           ; invader at base
 (game-over? (make-game INVADERS-AT-BASE MISSILES-1 TANK-GO-RT))
 #true) 

;(define (game-over? g) #false) ;stub

;; <Template taken from Game>

(define (game-over? g)
  (invaders-at-base? (game-invaders g)))

;; ------------------
;; Invaders -> Boolean
;; return true if 1 invader is at base (HEIGHT - INVADER-HEIGHT/2)
(check-expect (invaders-at-base? empty) #false)
(check-expect (invaders-at-base? INVADERS-NOT-AT-BASE) #false)
(check-expect (invaders-at-base? INVADERS-AT-BASE) #true)

;(define (invaders-at-base? loi) #false) ;stub

(define (invaders-at-base? loi)
  (cond [(empty? loi) #false]
        [else (if (invader-at-base? (first loi))
                  #true
                  (invaders-at-base? (rest loi)))]))

;; ------------------
;; Invader -> Boolean
;; return true if invader is at base
(check-expect (invader-at-base? INVADER-NOT-AT-BASE) #false)
(check-expect (invader-at-base? INVADER-AT-BASE) #true)

;(define (invader-at-base? i) #false) ;stub
            
(define (invader-at-base? invader)
  (>= (invader-y invader) (- HEIGHT INVADER-HEIGHT/2)))

  
