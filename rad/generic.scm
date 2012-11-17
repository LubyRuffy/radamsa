;;;
;;; Simple Generic Linear Mutations 
;;;

;; todo: stateful generic mutations
;;   mutator rs state arg ... → rs' state'
;;     automatic fold0-style behavior for state-dependent ones for first use
;;     state preservation strategies:
;;       - reservoir sampling -style
;;       - last state
;;       - always grow or probabilistic A + B?

(define-library (rad generic)

   (import
      (owl base)
      (rad fuse))

   (export
      list-del      ;; rs l → rs' l'
      list-del-seq  ;; rs l → rs' l'
      list-dup      ;; likewise
      list-clone    ;; ditto 
      list-repeat   ;; same
      list-swap     ;; etc
      list-perm     ;
      list-fuse
   )

   (begin

      ;; apply fn to the list at pos (fixnum range)
      (define (edit l pos fn)
         (if (eq? pos 0)
            (fn l)
            (lets ((pos _ (fx- pos 1)))
               (cons (car l) (edit (cdr l) pos fn)))))

      ;; delete a random element
      (define (list-del rs l)
         (if (null? l)
            (values rs l)
            (lets
               ((len (length l))
                (rs p (rand rs len)))
               (values rs (ldel l p)))))

      ;; delete a sequence of things
      (define (list-del-seq rs l)
         (let ((len (length l)))
            (if (= len 0)
               (values rs l)
               (lets
                  ((rs start (rand rs len))
                   (rs n (rand rs (- len start))) ;; <- could take min with rand-len
                   (hd tl (split l start)))
                  (values rs (append hd (drop tl n)))))))

      ;; duplicate a random element
      (define (list-dup rs l)
         (if (null? l)
            (values rs l)
            (lets
               ((len (length l))
                (rs p (rand rs len)))
               (values rs
                  (edit l p
                     (λ (l) 
                        (if (null? l)
                           l
                           (cons (car l) l))))))))

      (define (push e n l)
         (if (eq? n 0)
            l
            (push e (- n 1) (cons e l))))

      ;; repeat an element
      (define (list-repeat rs l)
         (if (null? l)
            (values rs l)
            (lets
               ((len (length l))
                (rs p (rand rs len))
                (rs n (rand-log rs 10))
                (n (max n 2)))
               (values rs
                  (edit l p
                     (λ (l) (if (null? l) l (push (car l) n l))))))))

      ;; clone a value to another position
      (define (list-clone rs l)
         (if (null? l)
            (values rs l)
            (lets
               ((len (length l))
                (rs from (rand rs len))
                (rs to (rand rs len)))
               (values rs (lins l to (lref l from))))))

      ;; swap two adjecent values 
      (define (list-swap rs l)
         (let ((len (length l)))
            (if (< len 2)
               (values rs l)
               (lets ((rs p (rand rs (- len 1))))
                  (values rs
                     (edit l p 
                        (λ (l) (ilist (cadr l) (car l) (cddr l)))))))))

      ;; permute values
      (define (list-perm rs l)
         (lets ((len (length l)))
            (if (< len 3)
               (values rs l)
               (lets 
                  ((rs from (rand rs (- len 3)))
                   (rs a (rand-range rs 2 (- len from)))
                   (rs b (rand-log rs 10))
                   (n (max 2 (min a b)))
                   (hs (take l from))
                   (tl (drop l from))
                   (rs perm (random-permutation rs (take tl n)))
                   (tl (append perm (drop tl n))))
                  (values rs (append hs tl))))))

      ;; clone a value to another position
      (define (list-clone rs l)
         (if (null? l)
            (values rs l)
            (lets
               ((len (length l))
                (rs from (rand rs len))
                (rs to (rand rs len)))
               (values rs (lins l to (lref l from))))))

      ;; connect prefix of al somewhere to bl, and make sure that (list-fuse l l) != l
      (define list-fuse fuse)


      ;;;
      ;;; Testing
      ;;;

      (define (print rs op data)
         (lets ((rs out (op rs data)))
            (print* (list " - " data " → " out " using " op))))

))

