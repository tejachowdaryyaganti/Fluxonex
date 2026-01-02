import { LightningElement, track } from 'lwc';
import searchSpeakers from '@salesforce/apex/SpeakerController.searchSpeakers';

export default class SpeakerSearch extends LightningElement {
    nameKey = '';
    speciality = '';
    @track speakers = [];

    options = [
        {label:'Apex', value:'Apex'},
        {label:'LWC', value:'LWC'},
        {label:'Integrations', value:'Integrations'},
        {label:'Architecture', value:'Architecture'}
    ];

    handleName(e){ this.nameKey = e.target.value; }
    handleSpec(e){ this.speciality = e.detail.value; }

    search(){
        searchSpeakers({nameKey:this.nameKey, speciality:this.speciality})
            .then(res => this.speakers = res);
    }
}