using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace WarEffects
{
	public class FX_ParticlePreview : MonoBehaviour
	{

		public GameObject[] Particles;
		public int[] CameraIndexs;
		public float[] ShootRates;
		public GameObject CameraObject;
		public Transform[] TransformTarget;
		public int IndexPosition;

		public int Index;
		public float ShootRate;
		private float timeTemp;

		void Start ()
		{

		}

		public void AddParticle (Vector3 position, Vector3 normal)
		{
		
			if (Index >= Particles.Length || Index < 0)
				Index = 0;
		
			if (Index >= 0 && Index < Particles.Length && Particles.Length > 0) {
				GameObject fx = (GameObject)GameObject.Instantiate (Particles [Index].gameObject, position, Particles [Index].gameObject.transform.rotation);
				fx.transform.forward = normal;
			}
		}

		void Update ()
		{
		
			if (Input.GetButton ("Fire1")) {
				if (Time.time > timeTemp + ShootRate) {
					var ray = Camera.main.ScreenPointToRay (Input.mousePosition);
					RaycastHit hit;
					if (Physics.Raycast (ray, out hit, 1000)) {
						AddParticle (hit.point + hit.normal * 0.1f, hit.normal);
					}
					timeTemp = Time.time;
				}
			}

			if (CameraIndexs.Length > 0 && Index < CameraIndexs.Length) {
				IndexPosition = CameraIndexs [Index];
			}

			if (ShootRates.Length > 0 && Index < ShootRates.Length) {
				ShootRate = ShootRates [Index];
			}

			if (CameraObject) {
				if (TransformTarget.Length > 0 && IndexPosition < TransformTarget.Length) {
					CameraObject.transform.localPosition = Vector3.Lerp (CameraObject.transform.localPosition, TransformTarget [IndexPosition].transform.localPosition, Time.deltaTime * 0.9f);
				}
			}
			if (Input.GetKeyDown (KeyCode.UpArrow)) {
				Index += 1;
				if (Index >= Particles.Length || Index < 0)
					Index = 0;
			}
			if (Input.GetKeyDown (KeyCode.DownArrow)) {
				Index -= 1;
				if (Index < 0)
					Index = Particles.Length - 1;
			}
		}

		void OnGUI ()
		{
			string FXname = "";
			if (Index >= 0 && Index < Particles.Length && Particles.Length > 0) {
				FXname = Particles [Index].name;
			}
			GUI.Label (new Rect (30, 30, Screen.width, 100), "" + FXname);
		
		
		
			if (GUI.Button (new Rect (30, Screen.height - 40, 100, 30), "Prev")) {
				Index -= 1;
			}
		
			if (GUI.Button (new Rect (140, Screen.height - 40, 100, 30), "Next")) {
				Index += 1;
			}
		

			if (Index < 0) {
				Index = Particles.Length - 1;
			}

		}
	
	}
}
