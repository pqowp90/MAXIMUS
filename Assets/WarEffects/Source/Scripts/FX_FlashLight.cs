using UnityEngine;
using System.Collections;

namespace WarEffects{

	public class FX_FlashLight : MonoBehaviour
	{

		public float LightMult = 2;
		private float intensityTemp = 0;

		void Update ()
		{
			if (!this.GetComponent<Light>())
				return;
		
			this.GetComponent<Light>().intensity -= LightMult * Time.deltaTime;
		}

		void Awake(){
			intensityTemp = this.GetComponent<Light>().intensity;
		}

		void OnEnable ()
		{
			this.GetComponent<Light>().intensity = intensityTemp;
		}
	}
}
