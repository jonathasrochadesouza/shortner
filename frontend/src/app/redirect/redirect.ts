import { Component, OnInit, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { environment } from '../../environments/environment';

@Component({
  selector: 'app-redirect',
  templateUrl: './redirect.html',
  styleUrl: './redirect.scss',
})
export class RedirectComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);

  ngOnInit(): void {
    const shortCode = this.route.snapshot.paramMap.get('shortCode') ?? '';
    setTimeout(() => {
      window.location.href = `${environment.apiBaseUrl}/${shortCode}`;
    }, 2000);
  }
}
