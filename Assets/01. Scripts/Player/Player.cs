using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;

public class Player : MonoBehaviour, IDamageable
{
    private float _hp = 100;
    private bool _isOpenBag;
    public TMP_Text ammoText;
    public ItemDB inventory;
    private PlayerAttack attack;


    [Header("Item")]
    [SerializeField] private LayerMask _itemLayer;
    [SerializeField] private float _itemFindRadius = 1f;

    [Header("Ore")]
    [SerializeField] private LayerMask _oreLayer;
    [SerializeField] private float _oreSearchRadius = 5f;
    public bool isMine = false;
    private bool _isFindOre = false;
    private Ore mineOre;

    [Header("Keybinds")]
    public KeyCode reloadKey = KeyCode.R;
    public KeyCode bagOpenKey = KeyCode.E;
    public KeyCode miningKey = KeyCode.F;

    public UnityEvent<float> OnDamageTaken { get; set; }
    public float Health { get => _hp; set => _hp = value; }

    private void Start()
    {
        attack = GetComponent<PlayerAttack>();
    }

    private void Update()
    {
        SearchItem();
        SearchOre();
        SwapWeapon();
        if (Input.GetButton("Fire1"))
        {
            Attak();
        }
        if(Input.GetKeyUp(miningKey))
        {
            isMine = true;
            _isFindOre = false;
            UIManager.Instance.MessageDown();
        }
        if(Input.GetKeyDown(reloadKey))
        {
            WeaponManager.Instance.StartCoroutine(WeaponManager.Instance.WeaponReloading());
        }

        ammoText.text = WeaponManager.Instance.weapon.ammoText;
    }

    private void SwapWeapon()
    {
        if(!WeaponManager.Instance.IsReloading)
        {
            float wheelInput = Input.GetAxis("Mouse ScrollWheel");
            if (wheelInput == 0) return;
            WeaponManager.Instance.SwapWeapon(wheelInput > 0);
        }
    }

    private void SearchItem()
    {
        Collider[] _item = Physics.OverlapSphere(transform.position, _itemFindRadius, _itemLayer);
        if (_item.Length > 0)
        {
            foreach (var item in _item)
            {
                ItemManager.Instance.GetItem(item.transform.parent.gameObject);
            }
        }
    }

    private void SearchOre()
    {
        RaycastHit hit;
        if(Physics.Raycast(transform.position, transform.forward + new Vector3(0, 0.5f, 0), out hit, _oreSearchRadius, _oreLayer))
        {
            if(!isMine && !_isFindOre)
            {
                UIManager.Instance.Message($"[ {miningKey} ] => Mine Mode Start");
                mineOre = hit.transform.GetComponent<Ore>();
                _isFindOre = true;
            }
        }
        else
        {
            if(isMine || _isFindOre)
            {
                UIManager.Instance.MessageDown();
                isMine = false;
                _isFindOre = false;
            }
        }
    }

    private void Attak()
    {
        if(isMine)
        {
            Mine();
            return;
        }

        if (attack.weapon == null) return;

        if (attack.weapon.bullet.ammo == 0) WeaponManager.Instance.StartCoroutine(WeaponManager.Instance.WeaponReloading());
        else if (!WeaponManager.Instance.IsReloading && !attack.AttackPossible)
        {
            attack.Attack();
        }
    }

    private void Mine()
    {
        Debug.Log("Mining");
        mineOre.TakeDamage(1);
        ItemManager.Instance.DropItem(mineOre.transform.position, mineOre.data.dropItem, mineOre.dropAmount);
    }

    public void TakeDamage(float damage)
    {
        _hp -= damage;
        UIManager.Instance.Popup(transform, damage.ToString(), true);

        if(_hp <= 0)
        {
            Debug.LogError("PLAYER DEATH");
        }
    }
}
