    using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.Rendering;

public class PlayerMovement : MonoBehaviour
{
    [Header("Movement")]
    public float moveSpeed;

    public float groundDrag;

    [SerializeField]
    private float runMultiplier = 1.5f;
    public float jumpForce;
    public float jumpCooldown;
    public float airMultiplier;
    bool readyToJump;

    [HideInInspector] public float walkSpeed;
    [HideInInspector] public float sprintSpeed;

    [Header("Keybinds")]
    public KeyCode jumpKey = KeyCode.Space;
    public KeyCode runKey = KeyCode.LeftShift;

    [Header("Ground Check")]
    public float playerHeight;
    public LayerMask whatIsGround;
    bool grounded;

    public Transform orientation;

    float horizontalInput;
    float verticalInput;

    Vector3 moveDirection;

    Rigidbody rb;

    Animator animator;

    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
        animator = GetComponentInChildren<Animator>();
    }

    private void Start()
    {
        rb.freezeRotation = true;
        readyToJump = true;
    }

    private void Update()
    {
        // ground check
        grounded = Physics.Raycast(transform.position, Vector3.down, 0.2f, whatIsGround);

        MyInput();
        SpeedControl();

        // handle drag
        if (grounded)
            rb.drag = groundDrag;
        else
            rb.drag = 0;

        if(Input.GetKeyDown(KeyCode.R))
        {
            ItemManager.Instance.DropItem(transform.position + new Vector3(10f, 10f, 0)); 
        }
    }

    private void FixedUpdate()
    {
        MovePlayer();
    }
    private float realHorizontalInput;
    private float realVerticalInput;
    [SerializeField]
    private float moveAnimationDamp = 5f;
    private float realRun;
    [SerializeField]
    private float runAnimationDamp = 10f;
    
    private void MyInput()
    {
        horizontalInput = Input.GetAxisRaw("Horizontal");
        verticalInput = Input.GetAxisRaw("Vertical");

        realHorizontalInput = Mathf.Lerp(realHorizontalInput, horizontalInput, Time.deltaTime * moveAnimationDamp);
        realVerticalInput = Mathf.Lerp(realVerticalInput, verticalInput, Time.deltaTime * moveAnimationDamp);

        animator.SetFloat("x", realHorizontalInput * realRun);
        animator.SetFloat("y", realVerticalInput * realRun);

        // when to jump
        // if (Input.GetKeyDown(jumpKey) && readyToJump && grounded) // 아니 누가 점프에 쿨다운을 넣어 이것땜에 점프 씹힘
        // {
        //     readyToJump = false;

        //     Jump();

        //     Invoke(nameof(ResetJump), jumpCooldown);
        // }
        if (Input.GetKeyDown(jumpKey) && grounded)
        {

            Jump();

        }

        if (Input.GetKey(runKey) && grounded)
        {
            realRun = Mathf.Lerp(realRun, 2, Time.deltaTime * runAnimationDamp);
        }
        else
        {
            realRun = Mathf.Lerp(realRun, 1, Time.deltaTime * runAnimationDamp);
        }
        
    }

    private void MovePlayer()
    {

        // calculate movement direction
        moveDirection = orientation.forward * verticalInput + orientation.right * horizontalInput;

        animator.SetBool("Walk", (moveDirection != Vector3.zero));

        // if(moveDirection == Vector3.zero) // 어차피 겟불하면 검색을 한번 해버려서 그냥 연산 안하고 넣어주는게 빠름
        // {
        //     if(animator.GetBool("Walk") == true)
        //         animator.SetBool("Walk", false);
        // }
        // else
        // {
        //     if (animator.GetBool("Walk") == false)
        //         animator.SetBool("Walk", true);
        // }
        animator.SetBool("IsGround", grounded);
        // on ground
        if (grounded)
            rb.AddForce(moveDirection.normalized * moveSpeed * (runMultiplier * realRun) * 10f, ForceMode.Force);

        // in air
        else if (!grounded)
            rb.AddForce(moveDirection.normalized * moveSpeed * (runMultiplier * realRun) * 10f * airMultiplier, ForceMode.Force);
    }

    private void SpeedControl()
    {
        Vector3 flatVel = new Vector3(rb.velocity.x, 0f, rb.velocity.z);

        // limit velocity if needed
        if (flatVel.magnitude > moveSpeed)
        {
            Vector3 limitedVel = flatVel.normalized * moveSpeed;
            rb.velocity = new Vector3(limitedVel.x, rb.velocity.y, limitedVel.z);
        }
    }

    private void Jump()
    {
        animator.SetTrigger("Jump");
        // reset y velocity
        rb.velocity = new Vector3(rb.velocity.x, 0f, rb.velocity.z);

        rb.AddForce(transform.up * jumpForce, ForceMode.Impulse);
    }

    private void ResetJump()
    {
        readyToJump = true;
    }


}